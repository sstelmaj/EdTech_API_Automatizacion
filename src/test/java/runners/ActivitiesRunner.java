package runners;

import com.intuit.karate.junit5.Karate;

class ActivitiesRunner {

    @Karate.Test
    Karate testActivities() {
        return Karate.run("classpath:features/activities").relativeTo(getClass());
    }
}
