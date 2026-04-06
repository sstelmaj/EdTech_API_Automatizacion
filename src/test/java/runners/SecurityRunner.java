package runners;

import com.intuit.karate.junit5.Karate;

class SecurityRunner {

    @Karate.Test
    Karate testSecurity() {
        return Karate.run("classpath:features/security").relativeTo(getClass());
    }
}
