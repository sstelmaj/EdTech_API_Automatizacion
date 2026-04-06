package runners;

import com.intuit.karate.junit5.Karate;

class CoursesRunner {

    @Karate.Test
    Karate testCourses() {
        return Karate.run("classpath:features/courses").relativeTo(getClass());
    }
}
