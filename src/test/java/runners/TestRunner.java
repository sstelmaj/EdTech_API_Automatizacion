package runners;

import com.intuit.karate.junit5.Karate;

class TestRunner {

    @Karate.Test
    Karate testAll() {
        return Karate.run("classpath:features").relativeTo(getClass());
    }

    // @Karate.Test
    // Karate testAuth() {
    //     return Karate.run("classpath:features/auth").relativeTo(getClass());
    // }

    // @Karate.Test
    // Karate testCourses() {
    //     return Karate.run("classpath:features/courses").relativeTo(getClass());
    // }

    // @Karate.Test
    // Karate testStudents() {
    //     return Karate.run("classpath:features/students").relativeTo(getClass());
    // }

    // @Karate.Test
    // Karate testActivities() {
    //     return Karate.run("classpath:features/activities").relativeTo(getClass());
    // }

    // @Karate.Test
    // Karate testGrades() {
    //     return Karate.run("classpath:features/grades").relativeTo(getClass());
    // }

    // @Karate.Test
    // Karate testReports() {
    //     return Karate.run("classpath:features/reports").relativeTo(getClass());
    // }

    // @Karate.Test
    // Karate testSecurity() {
    //     return Karate.run("classpath:features/security").relativeTo(getClass());
    // }
}
