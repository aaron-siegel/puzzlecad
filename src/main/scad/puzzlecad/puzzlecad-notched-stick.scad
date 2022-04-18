/* ====================================================================

  This is puzzlecad, an OpenSCAD library for modeling mechanical
  puzzles. It is provided as part of the Printable Puzzle Project:
  https://puzzlehub.org/ppp

  To obtain the latest version of puzzlecad:
  https://www.thingiverse.com/thing:3198014

  Puzzlecad code repository:
  https://github.com/aaron-siegel/puzzlecad

  puzzlecad is (c) 2019-2022 Aaron Siegel and is distributed under
  the MIT license. This means you may use or modify puzzlecad for any
  purposes, including commercial purposes, provided that you include
  the attribution "puzzlecad is (c) 2019-2022 Aaron Siegel" in any
  distributions or derivatives of puzzlecad, along with a copy of
  the MIT license.

  For details of this license, please refer to the LICENSE-MIT file
  distributed with puzzlecad, or visit:
  https://opensource.org/licenses/MIT

  NOTE THAT WHILE THE PUZZLECAD LIBRARY IS RELEASED UNDER THE MIT
  LICENSE, INDIVIDUAL PUZZLE DESIGNS (INCLUDING VARIOUS DESIGNS THAT
  ARE STORED IN THE PUZZLECAD GITHUB REPO) ARE SHARED UNDER A MORE
  RESTRICTIVE LICENSE. You may not use copyrighted puzzle designs for
  commercial purposes without explicit permission from the copyright
  holder(s).

==================================================================== */

$notched_stick_scale = 40;
$notched_stick_tolerance = 0.25;

module drilled_stick(length, radius, drilled_radius, sides, pattern, threads = undef, thread_marks = undef) {
    
    rotate([30, 0, 0]) {
        
        difference() {
            
            rotate([0, 90, 0])
            beveled_prism(regular_polygon(radius * $notched_stick_scale, sides), length * $notched_stick_scale, center = true);
                        
            for (k = [0:len(pattern)-1]) {
                shift = -(len(pattern) - 1) / 2 + k;
                translate([$notched_stick_scale * shift * sqrt(3) / 4, 0, 0])
                rotate([120 * pattern[k], 0, 0])
                rotate([0, 90 - critical_angle, 0]) {
                    cylinder(h = length * $notched_stick_scale, r = drilled_radius * $notched_stick_scale, center = true, $fn = 64);
                    if (!is_undef(thread_marks[k])) {
                        for (i = [1:thread_marks[k][0]]) {
                            translate([0, (-(thread_marks[k][0] - 1) / 2 + i - 1) * 1.5, radius * $notched_stick_scale - 1.5])
                            rotate([0, 90, 0])
                            cylinder(r = 0.5, h = drilled_radius * $notched_stick_scale + 1, $fn = 16);
                        }
                        for (i = [1:thread_marks[k][1]]) {
                            translate([0, (-(thread_marks[k][1] - 1) / 2 + i - 1) * 1.5, -(radius * $notched_stick_scale - 1.5)])
                            rotate([0, -90, 0])
                            cylinder(r = 0.5, h = drilled_radius * $notched_stick_scale + 1, $fn = 16);
                        }
                    }
                }
            }
            
        }
        
        if (!is_undef(threads)) {
            for (k = [0:len(threads)-1]) {
                if (threads[k] > 0) {
                    shift = -(len(pattern) - 1) / 2 + k;
                    translate([$notched_stick_scale * shift * sqrt(3) / 4, 0, 0])
                    rotate([120 * pattern[k], 0, 0])
                    rotate([0, 90 - critical_angle, 0]) {
                        translate([0, 0, 0.5])
                        thread(drilled_radius * $notched_stick_scale, threads[k] * $notched_stick_scale, inner_thread = true, $fn = 64);
                        translate([0, 0, -0.5 - threads[k] * $notched_stick_scale])
                        thread(drilled_radius * $notched_stick_scale, threads[k] * $notched_stick_scale, inner_thread = true, $fn = 64);
                        cylinder(h = 1, r = drilled_radius * $notched_stick_scale + 0.01, center = true, $fn = 64);
                    }
                }
            }
        }
        
    }
    
}

module dowel(length, radius, thread_length = 0) {
    
    beveled_prism(
        regular_polygon(radius * $notched_stick_scale - $notched_stick_tolerance, 64),
        (length - thread_length) * $notched_stick_scale,
        $burr_bevel = 0,
        $burr_bevel_adjustments = thread_length > 0 ? "z-=0.5" : "z-=0.5,z+=0.5"
    );
    
    if (thread_length > 0) {
        translate([0, 0, (length - thread_length) * $notched_stick_scale - 0.01]) {
            thread(radius * $notched_stick_scale, thread_length * $notched_stick_scale, $fn = 64, false);
        }
    }
    
}

function regular_polygon(radius, sides) = [ for (k = [sides-1:-1:0]) radius * [ cos(360 * k / sides), sin(360 * k / sides) ] ];

////////////////////////////////////////////////////////////////////
// HART SYMMETRIC STICKS

module unit_stick(length, radius, sides = 6, pre_rotate = 0) {
    
    scale($burr_scale)
    rotate([0, 90, 0])
    rotate([0, 0, pre_rotate])
    beveled_prism(regular_polygon(radius, sides), length, center = true, $burr_bevel = $burr_bevel / $burr_scale);
    
}

module cubic_stick_lattice(length, radius, angle = 0, sides = 6, pre_rotate = 0) {
    
    for (edge = unoriented_cube_edge_names) {
        
        rotate(cube_face_rotation(edge))
        rotate(cube_edge_pre_rotation(edge))
        translate($burr_scale * [0, 1/2, 1/2])
        rotate(a = angle, v = [0, 1, 1])
        unit_stick(length, radius, sides, pre_rotate, $burr_bevel = 0);
        
    }
    
}

module dodecahedral_stick_lattice(length, radius, angle = 0, sides = 5, pre_rotate = 0) {
    
    for (flip = [0,1], zrot = [0:4], frot = [0:(flip == 0 ? 3 : 1)]) {
        rotate([180 * flip, 0, 0])
        rotate(a = 72 * zrot, v = [0, -1, 1 / phi])
        rotate(a = 72 * frot, v = [0, 1, 1 / phi])
        translate($burr_scale * [0, phi * phi / 2, 0])
        rotate([0, angle, 0])
        unit_stick(length, radius, sides, pre_rotate);
    }
    
}

module drilled_dodecahedral_stick(length, radius, drilled_radius, angle = 0, sides = 5) {
    
    rotate([-36, 0, 0])
    rotate([0, -angle, 0])
    translate($burr_scale * [0, -phi * phi / 2, 0])
    difference() {
        
        translate($burr_scale * [0, phi * phi / 2, 0])
        rotate([0, angle, 0])
        unit_stick(length, radius, sides);
        
        for (flip = [0,1], zrot = [0:4], frot = [0:(flip == 0 ? 3 : 1)]) {
            rotate([180 * flip, 0, 0])
            rotate(a = 72 * zrot, v = [0, -1, 1 / phi])
            rotate(a = 72 * frot, v = [0, 1, 1 / phi])
            translate($burr_scale * [0, phi * phi / 2, 0])
            rotate([0, -angle, 0])
            unit_stick(length, drilled_radius, sides = 32, $burr_bevel = 0);
        }
        
    }
    
}

module truncated_icosahedral_stick_lattice(length, radius, angle = 0, sides = 6, parity = 0, pre_rotate = 0) {
    
    radial_fraction = 0.55279;      // ratio of pentagon radius to height = 2/sqrt(5*phi+5)
    
    for (flip = [0:1], zrot = [0:4], zrot2 = [0:4], frot = [parity:2:5]) {
        rotate([180 * flip, 0, 0])
        rotate(a = 72 * zrot2, v = [-(1 + (phi + 1) * radial_fraction), 3 * phi - phi * radial_fraction, 0])
        rotate(a = 72 * zrot, v = [1 + (phi + 1) * radial_fraction, 3 * phi - phi * radial_fraction, 0])
        rotate(a = 60 * frot, v = [0, 1, 0.38197])  // 0.38197 = tan(arcsin(x)) = x/sqrt(1-x^2) where x = sqrt(3)/(3*phi)
        translate($burr_scale * [0, 3 * phi / 2, 0])
        rotate([0, angle, 0])
        unit_stick(length, radius, sides, pre_rotate);
    }
    
}

////////////////////////////////////////////////////////////////////
// THREADS
// This code for generating threaded connectors is adapted from
// the public domain library by Trevor Moseley. The connectors are
// *not* ISO standard.

module thread(radius, height, inner_thread = false) {
    
	pitch = coarse_pitch(radius * 2);
	Rmin = radius - 5 * cos(30) * pitch / 8;	// as wiki Dmin
	turns = (height - pitch) / pitch;			// number of turns
	segments = turns * $fn;				        // number of segments
    
    if (!inner_thread) {
        cylinder(r = Rmin, h = height);
    }
        
	for (n = [0:segments]) {
        // Adjust Rmin slightly: for inner threads, increase by 0.01 to add some overlap;
        // for outer threads, reduce by 0.1 to add some overlap *and* provide a little tolerance.
		thread_segment(Rmin + (inner_thread ? 0.01 : -0.1), pitch, (height - pitch) / segments, n, inner_thread);
    }
    
}

module thread_segment(Rmin, pitch, segment_height, segment_number, inner_thread = false) {
    
	start_angle = segment_number * 360 / $fn + (inner_thread ? 180 : 0);		// angle to start of segment
	end_angle = start_angle + 1.01 * 360 / $fn;		                            // angle to end of segment (with overlap)
	z = segment_height * segment_number;
	Rmaj = Rmin + 5 * cos(30) * pitch / 8;
    
    Rvar = inner_thread ? Rmaj : Rmin;
    mult1 = inner_thread ? 3/8 : 3/4;
    mult2 = inner_thread ? 3/4 : 3/8;

	//   1,4
	//   |\
	//   | \  2,5
 	//   | / 
	//   |/
	//   0,3
	//  view from front (x & z) extruded in y by segment_number
    
	polyhedron(
		points = [
			[cos(start_angle) * Rvar, sin(start_angle) * Rvar, z],				                   	    // 0
			[cos(start_angle) * Rmin, sin(start_angle) * Rmin, z + mult1 * pitch],			            // 1
			[cos(start_angle) * Rmaj, sin(start_angle) * Rmaj, z + mult2 * pitch],		                // 2
			[cos(  end_angle) * Rvar, sin(  end_angle) * Rvar, z + segment_height],				        // 3
			[cos(  end_angle) * Rmin, sin(  end_angle) * Rmin, z + segment_height + mult1 * pitch],	    // 4
			[cos(  end_angle) * Rmaj, sin(  end_angle) * Rmaj, z + segment_height + mult2 * pitch]],	// 5
		faces = [
			[0, 1 ,2],			// near face
			[3, 5, 4],			// far face
			[0, 3, 4, 1],   	// left face
			[0, 2, 5, 3],	    // bottom face
			[1, 4, 5, 2]]	    // top face
    );
}

coarse_pitch_table = [[1, 0.25], [1.2, 0.25], [1.4, 0.3], [1.6, 0.35], [1.8, 0.35], [2, 0.4], [2.5, 0.45], [3, 0.5], [3.5, 0.6], [4, 0.7], [5, 0.8], [6, 1], [7, 1], [8, 1.25], [10, 1.5], [12, 1.75], [14, 2], [16, 2], [18, 2.5], [20, 2.5], [22, 2.5], [24, 3], [27, 3], [30, 3.5], [33, 3.5], [36, 4], [39, 4], [42, 4.5], [45, 4.5], [48, 5], [52, 5], [56, 5.5], [60, 5.5], [64, 6], [78, 5]];

function coarse_pitch(diameter) = lookup(diameter, coarse_pitch_table);
