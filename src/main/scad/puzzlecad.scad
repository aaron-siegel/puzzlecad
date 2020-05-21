// This is puzzlecad, an OpenSCAD library for modeling mechanical puzzles.
// To obtain the latest version of puzzlecad: https://www.thingiverse.com/thing:3198014
// Puzzlecad code repository: https://github.com/aaron-siegel/puzzlecad
// For an overview of interlocking puzzles: http://robspuzzlepage.com/interlocking.htm

// Puzzlecad is (c) 2019-2020 Aaron Siegel and is licensed for use under the
// Creative Commons - Attribution license. A copy of this license is available here:
// https://creativecommons.org/licenses/by/3.0/

include <puzzlecad/puzzlecad-util.scad>
include <puzzlecad/puzzlecad-geom.scad>
include <puzzlecad/puzzlecad-parser.scad>
include <puzzlecad/puzzlecad-polyhedra.scad>
include <puzzlecad/puzzlecad-layout.scad>
include <puzzlecad/puzzlecad-burr.scad>
include <puzzlecad/puzzlecad-2d.scad>

// Version ID for version check.

puzzlecad_version = "2.1";

// Default values for scale, inset, bevel, etc.:

$burr_scale = 11.15;
$burr_inset = 0.07;
$burr_bevel = 0.5;
$plate_width = 180;
$plate_depth = 180;
$plate_sep = 6;
$joint_inset = 0.015;
$joint_cutout = 0.5;
$diag_joint_scale = 0.4;
$diag_joint_position = 0.1;
$unit_beveled = false;
$auto_layout = false;
$post_rotate = [0, 0, 0];

// Optional parameters that can be used to increase
// the amount of beveling on outer edges of burr pieces:

$burr_outer_x_bevel = undef;
$burr_outer_y_bevel = undef;
$burr_outer_z_bevel = undef;

// Internal parameters used for the modeling and testing algorithms.
// Don't change them unless you know what you're doing!

$poly_err_tolerance = 1e-10;
$unit_test_tolerance = 1e-10;
$puzzlecad_debug = false;
$use_alternate_diag_inset_hack = false;

// Small constant value.

iota = 0.00001;
iota_vec = [iota, iota, iota];

if (list_contains(puzzlecad_version, "b")) {
    echo(str("NOTE: You are using a beta version of puzzlecad (version ", puzzlecad_version, ")."));
}
