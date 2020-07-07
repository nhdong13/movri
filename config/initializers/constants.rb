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
