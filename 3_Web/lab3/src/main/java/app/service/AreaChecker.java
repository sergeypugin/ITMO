package app.service;

import app.model.Point;

public final class AreaChecker {
    private AreaChecker() {
    }

    public static boolean contains(Point point) {
        double x = point.getX();
        double y = point.getY();
        double r = point.getR();

        if (x >= 0 && y >= 0) {
            return x * x + y * y <= (r / 2.0) * (r / 2.0);
        }
        if (x <= 0 && y <= 0) {
            return x >= -r && y >= -r / 2.0;
        }
        if (x >= 0 && y <= 0) {
            return x - y <= r / 2.0;
        }
        return false;
    }
}
