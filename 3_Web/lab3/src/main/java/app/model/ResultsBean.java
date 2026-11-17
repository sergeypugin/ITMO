package app.model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public final class ResultsBean implements Serializable {
    public static final String SESSION_ATTRIBUTE = "resultsBean";

    private static final long serialVersionUID = 1L;
    private static final int MAX_RESULTS = 500;

    private final List<CheckResult> results = new ArrayList<>();

    public synchronized void add(CheckResult result) {
        results.add(result);
        if (results.size() > MAX_RESULTS) {
            results.remove(0);
        }
    }

    public synchronized List<CheckResult> getResults() {
        return Collections.unmodifiableList(new ArrayList<>(results));
    }
}
