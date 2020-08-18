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

CAMORDER_TYPE = [
  'Prosumer',
  'ENG-style',
  'VR / 360˚',
  'Prosumer',
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
  'Full Frame'
]

ACCESSORY_TYPE = [
  'Production Tool',
  'Tethering',
  'Binoculars',
  'Covers',
  'Cables'
]

CABLE_TYPE = [
  'Coaxial Video Cable',
  'HDMI'
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
  'Tripod Heads',
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

ITEM_TYPE = [
  'Lens',
  'Mirrorless',
  'Flashes',
  'Memory',
  'Power',
  'Accessory',
  'Tripods',
  'Camera Support',
  'Lighting',
  'Drone',
  'Audio',
  'Monitoring',
  'Stabilizers',
  'Switcher',
]

CAMERA_TYPE = [
  "Camcorder",
  'DSLR',
  'Infrared',
  'Mirrorless',
  'Compact',
  'Stand Alone'
]