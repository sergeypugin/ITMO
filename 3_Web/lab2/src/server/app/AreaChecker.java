package app;

public final class AreaChecker {
    private AreaChecker() {
    }

    public static boolean isHit(double x, double y, double r) {
        boolean hit = false;
        if (x <= 0 && y >= 0) {
            hit = x * x + y * y <= r * r;
        } else if (x <= 0 && y <= 0) {
            hit = x >= -r && y >= -r;
        } else if (x >= 0 && y <= 0) {
            hit = x <= r / 2 && y >= 2 * x - r;
        }
        return hit;
    }
}
