package runners;

import com.intuit.karate.junit5.Karate;

class ReportsRunner {

    @Karate.Test
    Karate testReports() {
        return Karate.run("classpath:features/reports").relativeTo(getClass());
    }
}
