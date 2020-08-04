import React, { Component } from 'react';

class Currency extends Component {
  constructor(props) {
    super(props)
    this.handleOnChange = this.handleOnChange.bind(this)
  }

  handleOnChange(e) {
    let currency_settings = this.props.preferences.currency_settings || {}
    if(e.target.name == "conversion_enabled") {
      currency_settings[e.target.name] = !currency_settings[e.target.name]
    } else {
      currency_settings[e.target.name] = e.target.value
    }
    this.props.handleChangePreferences({...this.props.preferences, currency_settings: currency_settings})
  }

  render() {
    let currency_settings = this.props.preferences.currency_settings || {}
    return (
      <div className="section row">
        <label className="m-1">Currency</label>
        <div className="section-wrapper col-8 m-1 row">
          <div className="col-5 mr-3">
            <div className='checkbox-control'>
              <input 
                className='checkbox-input' 
                name='conversion_enabled' 
                type='checkbox'
                checked={currency_settings['conversion_enabled'] || false}
                onChange={this.handleOnChange}
                id='currency_conversion_enabled' />
              <label htmlFor='currency_conversion_enabled'
                      className='checkbox-label font-weight-regular mt-1'>
                Enable currency conversion
                <div className="font-size-14 text-gray">Even though prices are displayed in different currencies, orders will still be processed in your store's currency.</div>
              </label>
            </div>
            <label className='font-weight-regular'>Format</label>
            <select className="currency-format" name="format" value={currency_settings['format'] || ""} onChange={this.handleOnChange} >
              <option value='with_currency' >With currency ($10.00 CAD)</option>
            </select>
          </div>
          <div className="col-5">
            <div className='form-control'>
              <label className='font-weight-regular mt-1'>Supported currencies</label>
              <input type='text' name='supported_currencies' value={currency_settings['supported_currencies'] || ""} onChange={this.handleOnChange}/>
            </div>
            <div className='form-control'>
              <label className='font-weight-regular'>Default currency</label>
              <input type='text' name='default_currency' value={currency_settings['default_currency'] || ""} onChange={this.handleOnChange}/>
            </div>
          </div>
        </div>
      </div>
   );
 }
}

export default Currency;