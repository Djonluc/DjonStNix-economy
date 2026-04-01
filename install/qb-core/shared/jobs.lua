QBShared = QBShared or {}
QBShared.ForceJobDefaultDutyAtLogin = true -- true: Force duty state to jobdefaultDuty | false: set duty state from database last saved

-- ==============================================================================
-- 👑 DJONSTNIX GLOBAL ECONOMY BASELINE (HYBRID MODEL)
-- Time Scale: 35 IRL Hours = 1 In-Game Month
-- Check Interval: 15 Minutes (140 checks/month)
--
-- TIER 1 (Unskilled): ~$3,500/mo ($25 per check)
-- TIER 2 (Standard):  ~$6,000/mo ($43 per check)
-- TIER 3 (Advanced):  ~$9,500/mo ($68 per check)
-- TIER 4 (Executive): ~$15,000/mo ($107 per check)
-- ==============================================================================

QBShared.Jobs = {
	unemployed = { label = 'Civilian', defaultDuty = true, offDutyPay = false, grades = { ['0'] = { name = 'Freelancer', payment = 25 } } },
	bus = { label = 'Bus', defaultDuty = true, offDutyPay = false, grades = { ['0'] = { name = 'Driver', payment = 30 } } },
	judge = { label = 'Honorary', defaultDuty = true, offDutyPay = false, grades = { ['0'] = { name = 'Judge', payment = 107 } } },
	lawyer = { label = 'Law Firm', defaultDuty = true, offDutyPay = false, grades = { ['0'] = { name = 'Associate', payment = 68 } } },
	reporter = { label = 'Reporter', defaultDuty = true, offDutyPay = false, grades = { ['0'] = { name = 'Journalist', payment = 43 } } },
	trucker = { label = 'Trucker', defaultDuty = true, offDutyPay = false, grades = { ['0'] = { name = 'Driver', payment = 43 } } },
	tow = { label = 'Towing', defaultDuty = true, offDutyPay = false, grades = { ['0'] = { name = 'Driver', payment = 43 } } },
	garbage = { label = 'Garbage', defaultDuty = true, offDutyPay = false, grades = { ['0'] = { name = 'Collector', payment = 25 } } },
	vineyard = { label = 'Vineyard', defaultDuty = true, offDutyPay = false, grades = { ['0'] = { name = 'Picker', payment = 25 } } },
	hotdog = { label = 'Hotdog', defaultDuty = true, offDutyPay = false, grades = { ['0'] = { name = 'Sales', payment = 25 } } },

	police = {
		label = 'Law Enforcement',
		type = 'leo',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Recruit', payment = 43 },
			['1'] = { name = 'Officer', payment = 55 },
			['2'] = { name = 'Sergeant', payment = 68 },
			['3'] = { name = 'Lieutenant', payment = 85 },
			['4'] = { name = 'Chief', isboss = true, payment = 107 },
		},
	},
	ambulance = {
		label = 'EMS',
		type = 'ems',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Recruit', payment = 43 },
			['1'] = { name = 'Paramedic', payment = 55 },
			['2'] = { name = 'Doctor', payment = 68 },
			['3'] = { name = 'Surgeon', payment = 85 },
			['4'] = { name = 'Chief', isboss = true, payment = 107 },
		},
	},
	realestate = {
		label = 'Real Estate',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Recruit', payment = 25 },
			['1'] = { name = 'House Sales', payment = 43 },
			['2'] = { name = 'Business Sales', payment = 68 },
			['3'] = { name = 'Broker', payment = 85 },
			['4'] = { name = 'Manager', isboss = true, payment = 107 },
		},
	},
	taxi = {
		label = 'Taxi',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Recruit', payment = 25 },
			['1'] = { name = 'Driver', payment = 43 },
			['2'] = { name = 'Event Driver', payment = 55 },
			['3'] = { name = 'Sales', payment = 68 },
			['4'] = { name = 'Manager', isboss = true, payment = 85 },
		},
	},
	cardealer = {
		label = 'Vehicle Dealer',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Recruit', payment = 25 },
			['1'] = { name = 'Showroom Sales', payment = 43 },
			['2'] = { name = 'Business Sales', payment = 68 },
			['3'] = { name = 'Finance', payment = 85 },
			['4'] = { name = 'Manager', isboss = true, payment = 107 },
		},
	},
	mechanic = {
		label = 'LS Customs',
		type = 'mechanic',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Recruit', payment = 43 },
			['1'] = { name = 'Novice', payment = 55 },
			['2'] = { name = 'Experienced', payment = 68 },
			['3'] = { name = 'Advanced', payment = 85 },
			['4'] = { name = 'Manager', isboss = true, payment = 107 },
		},
	},
	mechanic2 = {
		label = 'Harmony Repair',
		type = 'mechanic',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Recruit', payment = 43 },
			['1'] = { name = 'Novice', payment = 55 },
			['2'] = { name = 'Experienced', payment = 68 },
			['3'] = { name = 'Advanced', payment = 85 },
			['4'] = { name = 'Manager', isboss = true, payment = 107 },
		},
	},
	mechanic3 = {
		label = 'Hayes Autos',
		type = 'mechanic',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Recruit', payment = 43 },
			['1'] = { name = 'Novice', payment = 55 },
			['2'] = { name = 'Experienced', payment = 68 },
			['3'] = { name = 'Advanced', payment = 85 },
			['4'] = { name = 'Manager', isboss = true, payment = 107 },
		},
	},
	beeker = {
		label = 'Beeker\'s Garage',
		type = 'mechanic',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Recruit', payment = 43 },
			['1'] = { name = 'Novice', payment = 55 },
			['2'] = { name = 'Experienced', payment = 68 },
			['3'] = { name = 'Advanced', payment = 85 },
			['4'] = { name = 'Manager', isboss = true, payment = 107 },
		},
	},
	bennys = {
		label = 'Benny\'s Original Motor Works',
		type = 'mechanic',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Recruit', payment = 43 },
			['1'] = { name = 'Novice', payment = 55 },
			['2'] = { name = 'Experienced', payment = 68 },
			['3'] = { name = 'Advanced', payment = 85 },
			['4'] = { name = 'Manager', isboss = true, payment = 107 },
		},
	},
}
