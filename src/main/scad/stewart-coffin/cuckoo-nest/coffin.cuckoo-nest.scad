/* ====================================================================

  This is a 3D model of a mechanical puzzle. It is released under
  the following license:

  Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported
  https://creativecommons.org/licenses/by-nc-nd/3.0/

  This means the model is licensed for personal, noncommercial use
  only. Anyone may print a copy for their own use, but selling or
  otherwise monetizing the model or print (or any derivatives) is
  prohibited. For details, refer to the summary at the above URL.

  Puzzle design (c) Stewart Coffin
  3D model (c) Aaron Siegel

==================================================================== */

include <puzzlecad.scad>

require_puzzlecad_version("2.4");

$notched_stick_scale = 50;          // in mm
$notched_stick_tolerance = 0.25;    // in mm

*hex_sticks();
*elbow_dowel();
*free_dowel();
*free_dowel_tighter();

hex_radius = sqrt(1/24);    // relative to scale; the "magic number" for locked nest et al
dowel_radius = 0.08;        // relative to scale; an arbitrary number that gives good results
stick_length = 1.5;         // relative to scale
thread_depth = hex_radius * 0.6;

critical_angle = 180 - 2 * atan(sqrt(2));       // Coffin's 70.5 degrees

module hex_sticks() {
    
    // All the sticks in Cuckoo Nest are identical except for the threads and thread marks,
    // so we abbreviate with the following submodule.
    
    module hex_stick(threads = undef, thread_marks = undef) {
        drilled_stick(
            length = stick_length,
            radius = hex_radius,
            drilled_radius = dowel_radius,
            sides = 6,
            pattern = [0, 1, 0],
            threads = threads,
            thread_marks = thread_marks
        );
    }
    
    y_spacing = hex_radius * 2 * $notched_stick_scale + 6;
    
    hex_stick();
    
    translate([0, y_spacing, 0])
    hex_stick(threads = [0, 0, thread_depth], thread_marks = [undef, undef, [3, 1]]);

    translate([0, y_spacing * 2, 0])
    hex_stick(threads = [0, 0, thread_depth], thread_marks = [undef, undef, [1, 3]]);
    
    translate([stick_length * $notched_stick_scale + 6, 0, 0])
    hex_stick(threads = [thread_depth, 0, 0], thread_marks = [[3, 1]]);
    
    for (k = [1:2]) {
        translate([stick_length * $notched_stick_scale + 6, y_spacing * k, 0])
        hex_stick(threads = [thread_depth, 0, 0], thread_marks = [[1, 3]]);
    }
    
}

module elbow_dowel() {
    
    dowel(stick_length / 2 - sqrt(3) / 4 - 0.5 / $notched_stick_scale, dowel_radius, thread_depth);
    translate([$notched_stick_scale * dowel_radius * 4, 0, 0])
    dowel(stick_length / 2 + sqrt(3) / 4 - 0.5 / $notched_stick_scale, dowel_radius, thread_depth);
    
}

module free_dowel() {
    
    dowel(stick_length, dowel_radius, 0);
    
}

module free_dowel_tighter() {

    free_dowel($notched_stick_tolerance = 0.02);

}
