package runners;

import com.intuit.karate.junit5.Karate;

class StudentsRunner {

    @Karate.Test
    Karate testStudents() {
        return Karate.run("classpath:features/students").relativeTo(getClass());
    }
}
