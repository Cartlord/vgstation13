#define CELL_VOLUME 2500	//liters in a cell
#define MOLES_CELLSTANDARD (ONE_ATMOSPHERE*CELL_VOLUME/(T20C*R_IDEAL_GAS_EQUATION))	//moles in a 2.5 m^3 cell at 101.325 Pa and 20 degC - about 103.934 in case you're searching
#define MOLES_CELLMARS (MARS_ATMOSPHERE*CELL_VOLUME/(T20C*R_IDEAL_GAS_EQUATION)) //Same as above but for mars (temperature is 20 degrees - it's assumed that it's noon on Mars)

#define O2STANDARD 0.21 //Percentage
#define N2STANDARD 0.79

#define MARS_ATMOSPHERE		0.6 //kPa
#define CO2MARS 0.96
#define N2MARS  0.04 //Mars atmosphere is actually 1.9% nitrogen, 1.9% argon with traces of other gases. Simplified to 4% nitrogen


#define MOLES_PLASMA_VISIBLE	0.7 //Moles in a standard cell after which plasma is visible
#define MOLES_CRYOTHEUM_VISIBLE	0.7 //Moles in a standard cell after which cryotheum is visible
#define MOLES_O2STANDARD (MOLES_CELLSTANDARD*O2STANDARD)	// O2 standard value (21%)
#define MOLES_N2STANDARD (MOLES_CELLSTANDARD*N2STANDARD)	// N2 standard value (79%)

#define MOLES_CO2MARS (MOLES_CELLMARS*CO2MARS)
#define MOLES_N2MARS  (MOLES_CELLMARS*N2MARS)

//These are for when a mob breathes poisonous air.
#define MIN_PLASMA_DAMAGE 1
#define MAX_PLASMA_DAMAGE 10

#define BREATH_VOLUME 0.5	//liters in a normal breath
#define BREATH_MOLES (ONE_ATMOSPHERE * BREATH_VOLUME /(T20C*R_IDEAL_GAS_EQUATION))
#define BREATH_PERCENTAGE (BREATH_VOLUME/CELL_VOLUME) //Amount of air to take a from a tile
#define HUMAN_NEEDED_OXYGEN	(MOLES_CELLSTANDARD*BREATH_PERCENTAGE*0.16) //Amount of air needed before pass out/suffocation commences

#define MINIMUM_AIR_RATIO_TO_SUSPEND 0.05 //Minimum ratio of air that must move to/from a tile to suspend group processing
#define MINIMUM_AIR_TO_SUSPEND (MOLES_CELLSTANDARD / CELL_VOLUME * MINIMUM_AIR_RATIO_TO_SUSPEND) //Minimum amount of air that has to move before a group processing can be suspended

#define MINIMUM_MOLES_DELTA_TO_MOVE (MOLES_CELLSTANDARD*MINIMUM_AIR_RATIO_TO_SUSPEND) //Either this must be active
#define MINIMUM_TEMPERATURE_TO_MOVE	(T20C+100) 		  //or this (or both, obviously)

#define MINIMUM_TEMPERATURE_RATIO_TO_SUSPEND 0.012
#define MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND 4 //Minimum temperature difference before group processing is suspended
#define MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER 0.5 //Minimum temperature difference before the gas temperatures are just set to be equal

#define MINIMUM_PRESSURE_DELTA_TO_SUSPEND 0.1 //The minimum pressure difference required for groups to remain separate (unless they meet other conditions). Chosen arbitrarily.
#define MINIMUM_PRESSURE_RATIO_TO_SUSPEND 0.05 //Minimum RELATIVE difference in pressure for groups to stay separate (unless they meet other conditions). Also chosen arbitrarily.

#define MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION		(T20C+10)
#define MINIMUM_TEMPERATURE_START_SUPERCONDUCTION	(T20C+200)

//Must be between 0 and 1. Values closer to 1 equalize temperature faster. Should not exceed 0.4 else strange heat flow occurs.
#define FLOOR_HEAT_TRANSFER_COEFFICIENT 0.4
#define WALL_HEAT_TRANSFER_COEFFICIENT 0.0
#define DOOR_HEAT_TRANSFER_COEFFICIENT 0.0
#define SPACE_HEAT_TRANSFER_COEFFICIENT 0.2 //a hack to partly simulate radiative heat
#define OPEN_HEAT_TRANSFER_COEFFICIENT 0.4
#define WINDOW_HEAT_TRANSFER_COEFFICIENT 0.1 //a hack for now

//Thermal dissipation
#define THERM_DISS_SCALING_FACTOR (1/2) //Per tick thermally dissipated energy is scaled by this much.
#define THERM_DISS_MAX_PER_TICK_TEMP_CHANGE_RATIO 0.1 //How much temperature can change in a single tick of thermal dissipation before the calculation has to be broken up to a more granular scale. 0.1 would be a temperature change of 10%
#define THERM_DISS_MAX_PER_TICK_SLICES 100 //How many slices the thermal dissipation calculation can be divided into per tick before the calculation exits early.
#define THERM_DISS_MAX_SAFE_TEMP 1000000000 //At temperatures beyond this limit, thermal dissipation switches to a simpler calculation to avoid blowing out any values.
#define HEAT_CONDUCTIVITY_REFRIGERATOR 0.05 //Heat conductivity of things like refrigerators.

// Fire Damage
#define CARBON_LIFEFORM_FIRE_RESISTANCE (200+T0C)
#define CARBON_LIFEFORM_FIRE_DAMAGE		4
#define HEAD_FIRE_DAMAGE_MULTIPLIER 1.5
#define CHEST_FIRE_DAMAGE_MULTIPLIER 1.5
#define GROIN_FIRE_DAMAGE_MULTIPLIER 1.0
#define LEGS_FIRE_DAMAGE_MULTIPLIER 0.6
#define ARMS_FIRE_DAMAGE_MULTIPLIER 0.4

//Plasma fire properties
#define PLASMA_MINIMUM_BURN_TEMPERATURE		(100+T0C)
#define PLASMA_FLASHPOINT 					(246+T0C)
#define PLASMA_UPPER_TEMPERATURE			(1370+T0C)
#define PLASMA_MINIMUM_OXYGEN_NEEDED		2
#define PLASMA_MINIMUM_OXYGEN_PLASMA_RATIO	20
#define PLASMA_OXYGEN_FULLBURN				10

// XGM gas flags.
// Whether this gas is "relevant", used for various things like whether to display it on an air alarm v.s. lump it in with "other gases".
#define XGM_GAS_NOTEWORTHY	1
// Some events will only be logged with this flag, i.e. opening a canister is only logged if it contains a logged gas.
#define XGM_GAS_LOGGED      2


#define TANK_LEAK_PRESSURE		(30.*ONE_ATMOSPHERE)	// Tank starts leaking
#define TANK_RUPTURE_PRESSURE	(40.*ONE_ATMOSPHERE) // Tank spills all contents into atmosphere
#define TANK_FRAGMENT_PRESSURE	(50.*ONE_ATMOSPHERE) // Boom 3x3 base explosion
#define TANK_FRAGMENT_SCALE	    (10.*ONE_ATMOSPHERE) // +1 for each SCALE kPa aboe threshold. Was 2 atm.

#define NORMPIPERATE 30					//pipe-insulation rate divisor
#define HEATPIPERATE 8					//heat-exch pipe insulation
#define FLOWFRAC 0.99				// fraction of gas transfered per process

#define BASE_ZAS_FUEL_REQ	0.1

//Snowmap when?
#define T_ARCTIC 223.65 //- 49.5 Celcius, taken from South Pole averages
#define MOLES_ARCTICSTANDARD (ONE_ATMOSPHERE*CELL_VOLUME/(T_ARCTIC*R_IDEAL_GAS_EQUATION)) //Note : Open air tiles obviously aren't 2.5 meters in height, but abstracted for now with infinite atmos
#define MOLES_O2STANDARD_ARCTIC MOLES_ARCTICSTANDARD*O2STANDARD	//O2 standard value (21%)
#define MOLES_N2STANDARD_ARCTIC MOLES_ARCTICSTANDARD*N2STANDARD	//N2 standard value (79%)
