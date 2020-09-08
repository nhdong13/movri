# CENTS
FEDEX_STANDARD_FEE = 2500
CONVERT_TO_CENT_VALUE = 100
LIMIT_WEIGHT_OF_FEDEX_SERVICE = 65

CANADA_PROVINCES = {
  'Alberta' => 'alberta',
  'British Columbia (BC)' => 'british_columbia',
  "Manitoba": 'manitoba',
  'New-Brunswick': 'new_brunswick',
  'Newfoundland and Labrador': 'newfoundland_and_labrador',
  'Northwest Territories': 'northwest_territories',
  'Nova Scotia': 'nova_scotia',
  'Nunavut': 'nunavut',
  'Ontario': 'ontario',
  'Prince Edward Island (PEI)': 'prince_edward_island',
  'Québec': 'quebec',
  'Saskatchewan': 'saskatchewan',
  'Yukon': 'yukon'
}

DEFAULT_STATE = "alberta"

OFFICE_ADDRESS = {
  state_or_province: 'british_columbia',
  postal_code: 'V3Z3S6',
  street1: 'Unit 210-19365, 22nd Avenue',
  city: 'Surrey',
  country: 'Canada',
  is_office_address: true
}

EMPTY_SHIPPING_ADDRESS = {
  is_office_address: false
}

DEFAULT_ADMIN_EMAIL = 'admin-movri@yopmail.com'
TRACKING_PACKAGE_WEB = 'https://www.fedex.com/en-ca/home.html'

BRAND = [
  'Canon',
  'FUJIFILM',
  'Lensbaby',
  'Nikon',
  'Olympus',
  'Panasonic',
  'Rokinon',
  'Sigma',
  'Sony',
  'Tamron',
  'Venus',
  'Voigtlander',
  'ARRI',
  'Vazen',
  'Insta360',
  'Z Cam',
  'Matterport',
  'Profoto',
  'Godox',
  'Westcott',
  'Manfrotto',
  'Avenger',
  'Kupo',
  'Impact',
  'SanDisk',
  'PNY',
  'Kingston',
  'Tether Tools',
  'Tenba',
  'Lowepro',
  'Pelican',
  'Think tank',
  'LensCoat',
  'Induro',
  'Gitzo',
  'GoPro',
  'PolarPro',
  'iTrunk',
  'Oben',
  'Benro',
  'Acratech',
  'ProMediaGear',
  'Novoflex',
  'Marrkins',
  'Redrock',
  'Blackmagic',
  'Litepanels',
  'Aputure',
  'Avolon',
  'Gary Fong',
  'Sekonic',
  'DJI',
  'Tiffen',
  'Rode',
  'Sennheiser',
  'K-Tek',
  'Zoom',
  'Motorola',
  'SmallHD',
  'Atomos',
  'Tilta',
  'Wooden Camera',
  'Bright Tangerine',
  'Teradek',
  'Dana Dolly',
  'Kessler',
  'Libec',
  'FLOWCINE',
  'Easyrig',
  'RigWheels',
  'Glidecam',
  'Ready Rig',
  'Moza',
  'Zhiyun',
  'Lanprate',
  'Zacuto',
  'Wooden Camera',
  'Mogami',
  'Avenger',
  'Ikan',
  'Neewer',
  'Belden',
  'Vello',
  'Pearstone',
  'Livestream',
  'SlingStudio',
]

CAMERA_SUPPORT_TYPE = [
  'Slider',
  'Matte Box'
]

MONITORING_TYPE = [
  'Monitor',
  'Wireless',
  'Streaming',
  'Viewfinder',
]

AUDIO_TYPE = [
  'Lavalier Mic',
  'Shotgun Mic',
  'Other',
  'Field Recorder'
]

FILTER_SIZE = [
  '67',
  '77',
  '82',
  '4x5.6',
  '4x4'
]

FILTER_STYLE = [
  'Circular'
]

FILTER_TYPE = [
  'Variable ND'
]

CAPACITY = [
  '512GB',
  '128GB',
  '64GB',
  '120GB',
  '256GB',
  '32GB',
]

COLOR_TEMPERATURE = [
  'Tungsten, Bi-Color, Daylight',
  'Daylight',
]

MEMORY_TYPE = [
  'CF',
  'SD',
  'Access Device',
  'XQD',
]

READ_TRANSFER_SPEED = [
  '525MB/s',
  '300MB/s',
  '90MB/s',
  '80MB/s',
  '95MB/s',
  '170MB/s',
  '160MB/s',
  '1700MB/s',
  '440MB/s',
  '100MB/s',
]

BUS_SPEED = [
  'Non UHS',
  'UHS-II',
  'UHS-I',
]

MOUNT = [
  'Canon EF',
  'Canon RF',
  'Fuji',
  'Nikon F',
  'Micro 4/3rds',
  'PL Mount',
  'Fixed Lens',
  'Sony E',
  'L Mount',
  'Sony A',
  'Universal up to 5/8',
  '5/8 / 16 mm Receptacle',
  '5/8 Receiver',
]

CAMCORDER_TYPE = [
  'Prosumer',
  'ENG-style',
  'VR / 360˚',
  'Cinema',
  'Action Cam'
]

LIGHTING_TYPE = [
  'Strobe Lighting',
  'Strobe Triggers',
  'Lightstands',
  'Backgrounds',
  'Continuous Lighting',
  'Modifiers',
  'Light Meters',
]

SENSOR_SIZE = [
  'CMOS',
  'Crop Frame',
  'Full Frame',
  'Micro 4/3rds',
  'Super 35'
]

ACCESSORY_TYPE = [
  'Production Tool',
  'Tethering',
  'Binoculars',
  'Covers',
  'Cables',
  'Filter'
]

CABLE_TYPE = [
  'Coaxial Video Cable',
  'HDMI',
  'SDI-BNC',
  'XLR',
]

ACTION_CAM_COMPATIBILITY = [
  'GoPro Hero 8',
]

COMPATIBILITY = [
  'Crop',
  'Full Frame',
  'Crop, Full Frame'
]


SUPPORT_TYPE = [
  'Backpacks & Cases',
  'Tripod Legs',
  'Monopod',
  'Fluidhead Kits, Monopod',
  'Arca-Swiss Plates',
  'Ballhead',
  'Tripod Heads',
  'Fluidhead',
  'Shoulder Mount',
  'Matte Box',
  'Dollies & Jibs'
]

HEAD_TYPE = [
  'Gimbal Head'
]

QUICK_RELEASE_SYSTEM = [
  'Arca Type'
]

POWER_COMPATIBILITY = [
  'Sony',
  'Nikon',
  'Canon',
  'Micro 4/3rds',
  'Fujifilm',
  'V Mount'
]

POWER_TYPE = [
  'Battery Grip',
  'Charger',
  'Battery',
]

LENS_TYPE = [
  'Wide Angle',
  'Cine',
  'Supertelephoto',
  'Telephoto',
  'Wide Angle and Normal Range',
  'Normal Range',
  'Specialty',
  'Wide Angle, Normal Range, and Telephoto',
  'Wide Angle and Tilt-Shift',
  'Wide Angle and Telephoto',
  'Wide Angle and Macro',
  'Normal Range and Tilt-Shift',
  'Normal Range and Wide Angle',
  'Normal Range and Telephoto',
  'Supertelephoto and Telephoto',
  'Macro and Telephoto',
  'Specialty and Wide Angle',
  'Cine and Wide Angle',
  'Cine and Normal Range'
]

ITEM_TYPE = {
  'Lens': 'lens',
  'Mirrorless': 'mirrorless',
  'Flashes': 'flashes',
  'Memory': 'memory',
  'Power': 'power',
  'Accessory': 'accessory',
  'Tripods': 'tripods',
  'Camera Support': 'camera_support',
  'Lighting': 'lighting',
  'Drone': 'drone',
  'Audio': 'audio',
  'Monitoring': 'monitoring',
  'Stabilizers': 'stabilizers',
  'Switcher': 'switcher',
  'Camera': 'camera'
}

CAMERA_TYPE = [
  "Camcorder",
  'DSLR',
  'Infrared',
  'Mirrorless',
  'Compact',
  'Stand Alone'
]

COVERAGE_OPTIONS = {
  'Movri Coverage': "movri_coverage",
  'No Coverage': "no_coverage"
}


DISCOUNT_CONSTANS = {
  '2_days' => 45.45,
  '3_days' => 61.04,
  '4_days' => 68.51,
  '5_days' => 71.95,
  '6_days' => 74.46,
  '7_days' => 76.07,
  '8_days' => 76.62,
  '9_days' => 77.34,
  '10_days' => 77.40,
  '11_days' => 77.92,
  '12_days' => 78.35,
  '13_days' => 78.72,
  '14_days' => 79.04,
  '15_days' => 79.48,
  '16_days' => 79.87,
  '17_days' => 80.21,
  '18_days' => 80.52,
  '19_days' => 80.79,
  '20_days' => 81.04,
  '21_days' => 81.26,
  '22_days' => 81.58,
  '23_days' => 81.93,
  '24_days' => 82.20,
  '25_days' => 82.44,
  '26_days' => 82.72,
  '27_days' => 82.97,
  '28_days' => 83.21,
  '29_days' => 83.34,
  '30_days' => 83.51,
  '31_days' => 83.75,
  '32_days' => 83.93,
  '33_days' => 84.10,
  '34_days' => 84.30,
  '35_days' => 84.45,
  '36_days' => 84.60,
  '37_days' => 84.73,
  '38_days' => 84.89,
  '39_days' => 85.01,
  '40_days' => 85.13,
  '41_days' => 85.18,
  '42_days' => 85.37,
  '43_days' => 85.47,
  '44_days' => 85.57,
  '45_days' => 85.66,
  '46_days' => 85.83,
  '47_days' => 85.96,
  '48_days' => 86.12,
  '49_days' => 86.24,
  '50_days' => 86.36,
  '51_days' => 86.50,
  '52_days' => 86.61,
  '53_days' => 86.74,
  '54_days' => 86.80,
  '55_days' => 86.94,
  '56_days' => 87.06,
  '57_days' => 87.15,
  '58_days' => 87.26,
  '59_days' => 87.34,
  '60_days' => 87.42,
  '61_days' => 87.50,
  '62_days' => 87.60,
  '63_days' => 87.69,
  '64_days' => 87.76,
  '65_days' => 87.85,
  '66_days' => 87.92,
  '67_days' => 88.00,
  '68_days' => 88.06,
  '69_days' => 88.12,
  '70_days' => 88.20,
  '71_days' => 88.26,
  '72_days' => 88.31,
  '73_days' => 88.38,
  '74_days' => 88.43,
  '75_days' => 88.48,
  '76_days' => 88.55,
  '77_days' => 88.60,
  '78_days' => 88.66,
  '79_days' => 88.67,
  '80_days' => 88.75,
  '81_days' => 88.81,
  '82_days' => 88.87,
  '83_days' => 88.91,
  '84_days' => 88.95,
  '85_days' => 89.00,
  '86_days' => 89.04,
  '87_days' => 89.09,
  '88_days' => 89.12,
  '89_days' => 89.16,
  '90_days' => 89.19,
}