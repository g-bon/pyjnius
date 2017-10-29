package org.jnius;

public class PropReader {
    public static void main(String[] args) {
        for (int ii = 0; ii < args.length; ++ii)
            System.out.println(System.getProperty(args[ii]));
    }
}

