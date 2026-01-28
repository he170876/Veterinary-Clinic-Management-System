package model;

/**
 * Domain model representing a Customer, mapped to the Customers table.
 * Wraps a User with the Customer-specific identifier.
 */
public class Customer {

    private int customerId;
    private User user;

    public Customer() {
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }
}

