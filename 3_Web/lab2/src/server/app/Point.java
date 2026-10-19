package app;

public record Point(double x, double y, double r, boolean hit, String serverTime, double executionTimeMs) {
    public String toJson() {
        return "{"
                + "\"x\":" + x
                + ",\"y\":" + y
                + ",\"r\":" + r
                + ",\"hit\":" + hit
                + ",\"serverTime\":" + jsonString(serverTime)
                + ",\"executionTimeMs\":" + executionTimeMs
                + "}";
    }

    public static String jsonString(String value) {
        String escaped = value.replace("\\", "\\\\").replace("\"", "\\\"");
        return "\"" + escaped + "\"";
    }
}
