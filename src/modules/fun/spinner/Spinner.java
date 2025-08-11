
//usr/bin/env jbang "$0" "$@" ; exit $?
import java.io.*;
import java.util.*;
import java.util.concurrent.atomic.AtomicBoolean;

public class Spinner {

    private static final Map<String, String[]> SPINNER_STYLES = Map.ofEntries(
            Map.entry("classic", new String[] { "|", "/", "-", "\\" }),
            Map.entry("dots", new String[] { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }),
            Map.entry("ball", new String[] { "●", "○", "●", "○" }),
            Map.entry("arrow", new String[] { "←", "↖", "↑", "↗", "→", "↘", "↓", "↙" }),
            Map.entry("braille", new String[] { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" }),
            Map.entry("pipe", new String[] { "┤", "┘", "┴", "└", "├", "┌", "┬", "┐" }),
            Map.entry("clock", new String[] { "🕛", "🕐", "🕑", "🕒", "🕓", "🕔", "🕕", "🕖", "🕗", "🕘", "🕙", "🕚" }),
            Map.entry("wave", new String[] { "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊", "🌊" }),
            Map.entry("matrix", new String[] { "░", "▒", "▓", "█", "▓", "▒", "░" }),
            Map.entry("runner", new String[] { "🏃", "🏃‍♂️", "🏃‍♀️" }),
            Map.entry("pulse", new String[] { "⬤", "○", "⬤", "○", "⬤" }));

    private static final Map<String, String> COLOR_CODES = Map.of(
            "red", "\033[31m",
            "green", "\033[32m",
            "yellow", "\033[33m",
            "blue", "\033[34m",
            "magenta", "\033[35m",
            "cyan", "\033[36m",
            "white", "\033[37m",
            "reset", "\033[0m");

    public static void main(String[] args) throws Exception {
        // Check if user asked for help
        for (String arg : args) {
            if (arg.equals("--help") || arg.equals("-h")) {
                printHelp();
                return; // Exit after showing help
            }
        }

        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        boolean hasInput = reader.ready(); // Detect if input is being piped
        String spinnerType = "classic";
        int delayMs = 100;
        String message = "";
        String color = "\033[0m";
        boolean multiMode = false;
        AtomicBoolean spinnerRunning = new AtomicBoolean(false);

        // Parse CLI args
        for (int i = 0; i < args.length; i++) {
            if (args[i].equals("--style") && i + 1 < args.length) {
                spinnerType = args[i + 1];
            } else if (args[i].equals("--speed") && i + 1 < args.length) {
                try {
                    delayMs = Integer.parseInt(args[i + 1]);
                } catch (NumberFormatException ignored) {
                }
            } else if (args[i].equals("--message") && i + 1 < args.length) {
                message = args[i + 1];
            } else if (args[i].equals("--color") && i + 1 < args.length) {
                color = COLOR_CODES.getOrDefault(args[i + 1], "\033[0m");
            } else if (args[i].equals("--multi")) {
                multiMode = true;
            }
        }

        if (multiMode) {
            runMultiSpinners(message, delayMs);
            return;
        }

        String[] frames = SPINNER_STYLES.getOrDefault(spinnerType, SPINNER_STYLES.get("classic"));
        runSingleSpinner(frames, delayMs, message, color, hasInput, reader, spinnerRunning);
    }

    private static void printHelp() {
        final String BOLD = "\033[1m";
        final String YELLOW = "\033[33m";
        final String CYAN = "\033[36m";
        final String GREEN = "\033[32m";
        final String BLUE = "\033[34m";
        final String RESET = "\033[0m";

        System.out.println(YELLOW + BOLD + "Usage: spinner [OPTIONS]" + RESET);
        System.out.println("A CLI spinner utility with multiple styles, colors, and streaming support.");

        System.out.println("\n" + BOLD + "Options:" + RESET);
        System.out.println("  " + CYAN + "--help, -h" + RESET + "        Show this help message");
        System.out
                .println("  " + CYAN + "--style <name>" + RESET + "   Choose a spinner style (e.g. dots, ball, arrow)");
        System.out.println(
                "  " + CYAN + "--speed <ms>" + RESET + "     Set spinner speed in milliseconds (default: 100)");
        System.out.println("  " + CYAN + "--message <text>" + RESET + " Display custom text next to the spinner");
        System.out.println(
                "  " + CYAN + "--color <name>" + RESET + "   Colorize spinner (red, green, yellow, blue, etc.)");
        System.out.println("  " + CYAN + "--multi" + RESET + "         Run all spinners at once in multiple lines");

        System.out.println("\n" + BOLD + "Available Spinner Styles:" + RESET);
        for (String key : SPINNER_STYLES.keySet()) {
            System.out.print(GREEN + key + RESET + "  ");
        }
        System.out.println("\n");

        System.out.println(BOLD + "Examples:" + RESET);
        System.out.println(BLUE + "  spinner --style dots --message \"Loading...\"" + RESET);
        System.out.println(BLUE + "  echo \"Hello World\" | spinner" + RESET);
        System.out.println(BLUE + "  ls -la | spinner --style ball --message \"Indexing files...\"" + RESET);
        System.out.println(BLUE + "  spinner --multi --speed 100 --message \"Spinning all the things!\"" + RESET);
    }

    private static void runSingleSpinner(String[] frames, int delay, String message, String color, boolean hasInput,
            BufferedReader reader, AtomicBoolean spinnerRunning) {
        final String resetColor = "\033[0m";

        Thread spinnerThread = new Thread(() -> {
            int i = 0;
            try {
                spinnerRunning.set(true);
                while (!Thread.currentThread().isInterrupted()) {
                    System.out.print("\r\033[K" + color + frames[i++ % frames.length] + " " + message + resetColor);
                    System.out.flush();
                    Thread.sleep(delay);
                }
            } catch (InterruptedException e) {
                System.out.print("\r\033[K" + resetColor);
            }
        });

        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            if (spinnerRunning.get()) {
                System.out.print("\r\033[K" + resetColor + "😠 Fine! Quitting early...\n");
            }
        }));

        if (!hasInput) {
            spinnerThread.start();
        }

        try {
            String line;
            while ((line = reader.readLine()) != null) {
                if (spinnerRunning.get()) {
                    System.out.print("\r\033[K");
                }
                System.out.println(line);
            }
        } catch (IOException ignored) {
        }

        if (spinnerRunning.get()) {
            spinnerThread.interrupt();
            try {
                spinnerThread.join();
            } catch (InterruptedException ignored) {
            }
        }
    }

    private static void runMultiSpinners(String message, int delay) {
        List<String[]> spinnerList = new ArrayList<>(SPINNER_STYLES.values());
        final int spinnerCount = spinnerList.size();
        final String resetColor = "\033[0m";

        for (int j = 0; j < spinnerCount; j++) {
            System.out.println();
        }
        final String moveUp = "\033[" + spinnerCount + "A";

        Thread spinnerThread = new Thread(() -> {
            int i = 0;
            try {
                while (!Thread.currentThread().isInterrupted()) {
                    System.out.print(moveUp);
                    for (String[] frames : spinnerList) {
                        System.out.print("\r\033[K" + frames[i % frames.length] + " " + message + "\n");
                    }
                    System.out.flush();
                    Thread.sleep(delay);
                    i++;
                }
            } catch (InterruptedException e) {
                System.out.print(resetColor + "\n⚠ Interrupted! Well, that was rude...\n");
            }
        });

        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            System.out.print(resetColor + "\n😠 Fine! Quitting early...\n");
        }));

        spinnerThread.start();

        while (true) {
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                break;
            }
        }
    }
}
