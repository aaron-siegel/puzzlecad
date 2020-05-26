package org.puzzlecad;

public class Arguments {

    int[] filterByColor;
    String filename;
    boolean stdout;

    public Arguments(String[] args) throws Exception {

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
