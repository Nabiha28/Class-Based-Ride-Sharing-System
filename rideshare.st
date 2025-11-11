"!
Ride Sharing System - Smalltalk Implementation
Demonstrates encapsulation, inheritance, and polymorphism
!

Object subclass: #Ride
	instanceVariableNames: 'rideID pickupLocation dropoffLocation distanceMiles'
	classVariableNames: 'NextID'
	poolDictionaries: ''
	category: 'RideSharing'!

"Ride class initialization"
Ride class >> initialize
	NextID := 1!

"Instance creation"
Ride class >> from: pickup to: dropoff distance: distance
	^ self new initializeFrom: pickup to: dropoff distance: distance

"Instance methods"
Ride >> initializeFrom: pickup to: dropoff distance: distance
	rideID := NextID.
	NextID := NextID + 1.
	pickupLocation := pickup.
	dropoffLocation := dropoff.
	distanceMiles := distance

"Encapsulated accessors - controlling access to private data"
Ride >> rideID
	^ rideID

Ride >> pickupLocation
	^ pickupLocation

Ride >> dropoffLocation
	^ dropoffLocation

Ride >> distanceMiles
	^ distanceMiles

"Polymorphic fare calculation - base implementation"
Ride >> fare
	| basePerMile minFare |
	basePerMile := 1.0.
	minFare := 2.0.
	^ ((basePerMile * distanceMiles) max: minFare)

"Polymorphic ride details display"
Ride >> rideDetails
	Transcript show: 'Ride #', rideID asString, ' | From: ', pickupLocation, ' -> To: ', dropoffLocation, 
		' | Distance: ', (distanceMiles asString: 3), ' miles | Fare: $', 
		(self fare asString: 3); cr

"StandardRide subclass - demonstrates inheritance"
Ride subclass: #StandardRide
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'RideSharing'

"StandardRide implementation"
StandardRide >> fare
	| perMile bookingFee raw minFare |
	perMile := 1.5.
	bookingFee := 1.0.
	raw := (perMile * self distanceMiles) + bookingFee.
	minFare := 3.0.
	^ (raw max: minFare)

StandardRide >> rideDetails
	Transcript show: '[Standard] '.
	super rideDetails

"PremiumRide subclass - demonstrates inheritance and polymorphism"
Ride subclass: #PremiumRide
	instanceVariableNames: 'luxuryMultiplier'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'RideSharing'

"PremiumRide creation"
PremiumRide class >> from: pickup to: dropoff distance: distance multiplier: multiplier
	^ self new initializeFrom: pickup to: dropoff distance: distance multiplier: multiplier

PremiumRide >> initializeFrom: pickup to: dropoff distance: distance multiplier: multiplier
	self initializeFrom: pickup to: dropoff distance: distance.
	luxuryMultiplier := multiplier

"PremiumRide fare calculation - overrides parent"
PremiumRide >> fare
	| basePerMile surge raw minFare |
	basePerMile := 2.5.
	surge := 2.0.
	raw := ((basePerMile * self distanceMiles) * luxuryMultiplier) + surge.
	minFare := 10.0.
	^ (raw max: minFare)

PremiumRide >> rideDetails
	Transcript show: '[Premium]  '.
	super rideDetails

"Driver class - demonstrates encapsulation"
Object subclass: #Driver
	instanceVariableNames: 'driverID name rating assignedRides'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'RideSharing'

"Driver creation and initialization"
Driver class >> id: id name: driverName rating: driverRating
	^ self new initializeID: id name: driverName rating: driverRating

Driver >> initializeID: id name: driverName rating: driverRating
	driverID := id.
	name := driverName.
	rating := driverRating.
	assignedRides := OrderedCollection new

"Encapsulated method to add ride"
Driver >> addRide: aRide
	assignedRides add: aRide

"Encapsulated method to get assigned rides count"
Driver >> assignedCount
	^ assignedRides size

"Encapsulated method to get driver info"
Driver >> getDriverInfo
	| totalEarnings |
	Transcript show: 'Driver ID: ', driverID asString, ' | Name: ', name, 
		' | Rating: ', (rating asString: 3); cr.
	Transcript show: 'Assigned rides (', assignedRides size asString, '):'; cr.
	totalEarnings := 0.
	assignedRides do: [:ride |
		ride rideDetails.
		totalEarnings := totalEarnings + ride fare
	].
	Transcript show: 'Total earnings from assigned rides: $', 
		(totalEarnings asString: 3); cr

"Rider class - demonstrates encapsulation"
Object subclass: #Rider
	instanceVariableNames: 'riderID name requestedRides'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'RideSharing'

"Rider creation and initialization"
Rider class >> id: id name: riderName
	^ self new initializeID: id name: riderName

Rider >> initializeID: id name: riderName
	riderID := id.
	name := riderName.
	requestedRides := OrderedCollection new

"Encapsulated method to request ride"
Rider >> requestRide: aRide
	requestedRides add: aRide

"Encapsulated method to view rides"
Rider >> viewRides
	Transcript show: 'Rider ID: ', riderID asString, ' | Name: ', name, 
		' | Ride history (', requestedRides size asString, '):'; cr.
	requestedRides do: [:ride |
		ride rideDetails
	]

"=== Main Demo Script ==="
"| Create the Ride Sharing System"
Transcript clear.

Ride initialize.

"Create drivers and riders"
Transcript show: '=== Ride Sharing System Demo ==='; cr; cr.

| driver1 driver2 rider1 rider2 allRides r1 r2 r3 r4 totalRevenue |

driver1 := Driver id: 101 name: 'Aisha Khan' rating: 4.92.
driver2 := Driver id: 102 name: 'Carlos Mendez' rating: 4.80.

rider1 := Rider id: 201 name: 'Nabiha S.'.
rider2 := Rider id: 202 name: 'Sam Lee'.

allRides := OrderedCollection new.

"Create various rides (mix of standard and premium)"
r1 := StandardRide from: 'Downtown' to: 'Airport' distance: 18.4.
r2 := PremiumRide from: 'Mall' to: 'University' distance: 7.2 multiplier: 1.5.
r3 := StandardRide from: 'Home' to: 'Office' distance: 4.5.
r4 := PremiumRide from: 'Hotel' to: 'Convention Center' distance: 12.0 multiplier: 1.8.

"Add rides to collection for polymorphic processing"
allRides add: r1.
allRides add: r2.
allRides add: r3.
allRides add: r4.

"Display all rides polymorphically"
Transcript show: 'All rides (polymorphic display):'; cr.
allRides do: [:ride | ride rideDetails].
Transcript cr.

"Assign rides to drivers"
driver1 addRide: r1.
driver1 addRide: r3.
driver2 addRide: r2.
driver2 addRide: r4.

"Request rides for riders"
rider1 requestRide: r1.
rider1 requestRide: r2.
rider2 requestRide: r3.
rider2 requestRide: r4.

"Display driver summaries"
Transcript show: '---- Driver Summaries ----'; cr.
driver1 getDriverInfo.
Transcript cr.
driver2 getDriverInfo.
Transcript cr.

"Display rider histories"
Transcript show: '---- Rider Histories ----'; cr.
rider1 viewRides.
Transcript cr.
rider2 viewRides.
Transcript cr.

"Calculate total system revenue"
totalRevenue := 0.
allRides do: [:ride |
	totalRevenue := totalRevenue + ride fare
].

Transcript show: 'Total revenue from all created rides: $', 
	(totalRevenue asString: 3); cr.

Transcript show: '=== End Demo ==='; cr.
