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

include <puzzlecad/puzzlecad-util.scad>
include <puzzlecad/puzzlecad-geom.scad>
include <puzzlecad/puzzlecad-parser.scad>
include <puzzlecad/puzzlecad-polyhedra.scad>
include <puzzlecad/puzzlecad-layout.scad>
include <puzzlecad/puzzlecad-burr.scad>
include <puzzlecad/puzzlecad-burr-stick.scad>
include <puzzlecad/puzzlecad-notched-stick.scad>
include <puzzlecad/puzzlecad-boxes.scad>
include <puzzlecad/puzzlecad-2d.scad>

// Version ID for version check.

puzzlecad_version = "2.4";

// Default values for scale, inset, bevel, etc.:

$burr_scale = 11.15;
$burr_inset = 0.07;
$burr_bevel = 0.5;

$box_wall_thickness = 6;
$box_inset = 0.2;
$box_cutout_inset = undef;
$box_bevel = 0.5;

$plate_width = 180;
$plate_depth = 180;
$plate_sep = 6;

$joint_inset = 0.015;
$joint_cutout = 0.5;
$diag_joint_scale = 0.4;
$diag_joint_position = 0.1;
$short_joints = false;

$unit_beveled = false;
$auto_layout = false;
$detached_joints = false;
$post_rotate = [0, 0, 0];

// Optional parameters that can be used to increase
// the amount of beveling on outer edges of burr pieces:

$burr_bevel_adjustments = undef;
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
