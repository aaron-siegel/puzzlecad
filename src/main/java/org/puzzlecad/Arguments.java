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

package org.puzzlecad;

public class Arguments {

    int[] filterByColor;
    String filename;
    String header;
    boolean stdout;

    public Arguments(String[] args) {

        for (int i = 0; i < args.length; i++) {

            if (args[i].startsWith("-")) {

                if (args[i].equals("--filter-by-color")) {

                    if (filterByColor == null && i + 1 < args.length) {
                        String[] colorsStr = args[i + 1].split(",");
                        filterByColor = new int[colorsStr.length];
                        for (int j = 0; j < filterByColor.length; j++) {
                            filterByColor[j] = Integer.parseInt(colorsStr[j]);
                        }
                        i++;
                    } else {
                        throw new InvalidCliException();
                    }

                } else if (args[i].equals("--stdout")) {

                    stdout = true;

                } else if (args[i].equals("--header")) {

                    if (header == null && i + 1 < args.length) {
                        header = args[i+1];
                        i++;
                    } else {
                        throw new InvalidCliException();
                    }

                } else {

                    throw new InvalidCliException();

                }

            } else {

                if (filename == null) {
                    filename = args[i];
                } else {
                    throw new InvalidCliException();
                }

            }

        }

    }

    public static class InvalidCliException extends RuntimeException {

    }

}
