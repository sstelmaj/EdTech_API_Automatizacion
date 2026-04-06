package runners;

import com.intuit.karate.junit5.Karate;

class GradesRunner {

    @Karate.Test
    Karate testGrades() {
        return Karate.run("classpath:features/grades").relativeTo(getClass());
    }
}
