// ridesharing.cpp
#include <iostream>
#include <string>
#include <vector>
#include <memory>
#include <iomanip>
#include <numeric>

class Ride {
private:
    static int nextID;            // internal automatic id generator (encapsulation)
    int rideID;
    std::string pickupLocation;
    std::string dropoffLocation;
    double distanceMiles;         // miles

public:
    Ride(const std::string &pickup, const std::string &dropoff, double distance)
        : rideID(nextID++), pickupLocation(pickup), dropoffLocation(dropoff), distanceMiles(distance) {}

    virtual ~Ride() = default;

    // Encapsulated accessors
    int getRideID() const { return rideID; }
    std::string getPickup() const { return pickupLocation; }
    std::string getDropoff() const { return dropoffLocation; }
    double getDistance() const { return distanceMiles; }

    // Polymorphic fare calculation: overridden by subclasses
    virtual double fare() const {
        // Base generic formula (very basic; subclasses override for specific behaviour)
        const double basePerMile = 1.0;
        double rawFare = basePerMile * distanceMiles;
        return std::max(2.0, rawFare); // minimum fare of $2.00
    }

    // Polymorphic details printer
    virtual void rideDetails() const {
        std::cout << "Ride #" << rideID
                  << " | From: " << pickupLocation
                  << " -> To: " << dropoffLocation
                  << " | Distance: " << std::fixed << std::setprecision(2) << distanceMiles << " miles"
                  << " | Fare: $" << std::fixed << std::setprecision(2) << fare()
                  << std::endl;
    }
};

int Ride::nextID = 1; // initialize static ID counter


// Specific Ride Subclass: StandardRide
class StandardRide : public Ride {
public:
    StandardRide(const std::string &pickup, const std::string &dropoff, double distance)
        : Ride(pickup, dropoff, distance) {}

    double fare() const override {
        const double perMile = 1.5;   // $1.5 per mile for standard
        double raw = perMile * getDistance();
        // example minimal booking fee
        double bookingFee = 1.0;
        return std::max(3.0, raw + bookingFee);
    }

    void rideDetails() const override {
        std::cout << "[Standard] ";
        Ride::rideDetails(); // reuse base formatting
    }
};


// Specific Ride Subclass: PremiumRide
class PremiumRide : public Ride {
private:
    double luxuryMultiplier;
public:
    PremiumRide(const std::string &pickup, const std::string &dropoff, double distance, double multiplier = 2.0)
        : Ride(pickup, dropoff, distance), luxuryMultiplier(multiplier) {}

    double fare() const override {
        const double basePerMile = 2.5;   // base for premium
        double raw = basePerMile * getDistance() * luxuryMultiplier;
        // premium has higher base/minimum
        double surge = 2.0; // example
        return std::max(10.0, raw + surge);
    }

    void rideDetails() const override {
        std::cout << "[Premium]  ";
        Ride::rideDetails();
    }
};


// Driver class demonstrating encapsulation: assignedRides is private
class Driver {
private:
    int driverID;
    std::string name;
    double rating; // 0.0 - 5.0
    std::vector<std::shared_ptr<Ride>> assignedRides; // private, only accessible via methods

public:
    Driver(int id, const std::string &n, double r = 5.0) : driverID(id), name(n), rating(r) {}

    // Add a ride to the driver's completed/assigned list
    void addRide(const std::shared_ptr<Ride> &ride) {
        assignedRides.push_back(ride);
    }

    // Get driver info and summary (safe exposure of data through method — encapsulation)
    void getDriverInfo() const {
        std::cout << "Driver ID: " << driverID << " | Name: " << name << " | Rating: " << std::fixed << std::setprecision(2) << rating << std::endl;
        std::cout << "Assigned rides (" << assignedRides.size() << "):" << std::endl;
        double totalEarnings = 0.0;
        for (const auto &r : assignedRides) {
            if (r) {
                r->rideDetails();
                totalEarnings += r->fare();
            }
        }
        std::cout << "Total earnings from assigned rides: $" << std::fixed << std::setprecision(2) << totalEarnings << std::endl;
    }

    // Provide count accessor
    size_t getAssignedCount() const { return assignedRides.size(); }

    // Optionally clear assigned rides (example of encapsulated operation)
    void clearAssignedRides() { assignedRides.clear(); }
};


// Rider class demonstrating encapsulation for requestedRides
class Rider {
private:
    int riderID;
    std::string name;
    std::vector<std::shared_ptr<Ride>> requestedRides;

public:
    Rider(int id, const std::string &n) : riderID(id), name(n) {}

    // Request a ride - rider stores a reference to their rides
    void requestRide(const std::shared_ptr<Ride> &ride) {
        requestedRides.push_back(ride);
    }

    // View ride history
    void viewRides() const {
        std::cout << "Rider ID: " << riderID << " | Name: " << name << " | Ride history (" << requestedRides.size() << "):" << std::endl;
        for (const auto &r : requestedRides) {
            if (r) r->rideDetails();
        }
    }
};


// Example system-level operation demonstrating polymorphism and usage
int main() {
    std::cout << "=== Ride Sharing System Demo ===\n\n";

    // Create drivers and riders
    Driver driver1(101, "Aisha Khan", 4.92);
    Driver driver2(102, "Carlos Mendez", 4.80);

    Rider rider1(201, "Nabiha S.");
    Rider rider2(202, "Sam Lee");

    // Polymorphic storage of different ride types
    std::vector<std::shared_ptr<Ride>> allRides;

    // Create some rides (mix of standard and premium)
    auto r1 = std::make_shared<StandardRide>("Downtown", "Airport", 18.4);
    auto r2 = std::make_shared<PremiumRide>("Mall", "University", 7.2, 1.5);
    auto r3 = std::make_shared<StandardRide>("Home", "Office", 4.5);
    auto r4 = std::make_shared<PremiumRide>("Hotel", "Convention Center", 12.0);

    // Store rides in a single container (polymorphism)
    allRides.push_back(r1);
    allRides.push_back(r2);
    allRides.push_back(r3);
    allRides.push_back(r4);

    // Demonstrate polymorphic calls to fare() and rideDetails()
    std::cout << "All rides (polymorphic display):\n";
    for (const auto &ridePtr : allRides) {
        // even though type is shared_ptr<Ride>, overridden fare()/rideDetails() will run
        ridePtr->rideDetails();
    }
    std::cout << std::endl;

    // Assign some rides to drivers and riders
    driver1.addRide(r1);
    driver1.addRide(r3);
    driver2.addRide(r2);
    driver2.addRide(r4);

    rider1.requestRide(r1);
    rider1.requestRide(r2);
    rider2.requestRide(r3);
    rider2.requestRide(r4);

    // Show driver info and computed earnings
    std::cout << "---- Driver Summaries ----\n";
    driver1.getDriverInfo();
    std::cout << std::endl;
    driver2.getDriverInfo();
    std::cout << std::endl;

    // Show rider ride histories
    std::cout << "---- Rider Histories ----\n";
    rider1.viewRides();
    std::cout << std::endl;
    rider2.viewRides();
    std::cout << std::endl;

    // Demonstrate aggregated operations (example: total fares across all rides)
    double totalSystemRevenue = 0.0;
    for (const auto &r : allRides) totalSystemRevenue += r->fare();

    std::cout << "Total revenue from all created rides: $" << std::fixed << std::setprecision(2) << totalSystemRevenue << std::endl;

    std::cout << "\n=== End Demo ===\n";
    return 0;
}
