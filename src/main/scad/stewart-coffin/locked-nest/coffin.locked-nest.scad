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

$notched_stick_scale = 40;          // in mm
$notched_stick_tolerance = 0.25;    // in mm

*free_stick();
*elbow_stick();
*free_dowel();
*elbow_dowel();

hex_radius = sqrt(1/24);    // relative to scale; the "magic number" for locked nest et al
dowel_radius = 0.08;        // relative to scale; an arbitrary number that gives good results
stick_length = 2.5;         // relative to scale
thread_depth = hex_radius * 0.6;

critical_angle = 180 - 2 * atan(sqrt(2));       // Coffin's 70.5 degrees

module free_stick() {
    drilled_stick(
        length = stick_length,
        radius = hex_radius,
        drilled_radius = dowel_radius,
        sides = 6,
        pattern = [0, 1, 2, 0, 1]
    );
}

module elbow_stick() {
    drilled_stick(
        length = stick_length,
        radius = hex_radius,
        drilled_radius = dowel_radius,
        sides = 6,
        pattern = [0, 1, 2, 0, 1],
        threads = [thread_depth],
        thread_marks = [[3, 1]]
    );
}

module elbow_dowel() {
    
    dowel(stick_length / 2 - sqrt(3) / 2 - 0.5 / $notched_stick_scale, dowel_radius, thread_depth);
    translate([$notched_stick_scale * dowel_radius * 4, 0, 0])
    dowel(stick_length / 2 + sqrt(3) / 2 - 0.5 / $notched_stick_scale, dowel_radius, thread_depth);
    
}

module free_dowel() {
    
    dowel(stick_length, dowel_radius, 0);
    
}
