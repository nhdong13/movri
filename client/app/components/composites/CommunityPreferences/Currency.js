import React, { Component } from 'react';
import MultiSelect from "react-multi-select-component";
import currency_iso from '../../../assets/json/currency_iso.json'

const currencyOptions = () => {
  const values = Object.keys(currency_iso)
  let options = []
  values.map(v => {
    options.push({value: v, label: `${currency_iso[v].name}(${v.toUpperCase()})`})
  })
  return options
}

class Currency extends Component {
  constructor(props) {
    super(props)
    this.currencyOptions = currencyOptions()
    this.state = {
      currencyOptions: this.currencyOptions
    }

    this.handleOnChange = this.handleOnChange.bind(this)
    this.handleOnChangeCurrencies = this.handleOnChangeCurrencies.bind(this)
    this.handleOnChangeDefaultCurrency = this.handleOnChangeDefaultCurrency.bind(this)
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

  handleOnChangeCurrencies(items) {
    let currency_settings = this.props.preferences.currency_settings || {}
    currency_settings['supported_currencies'] = items
    this.props.handleChangePreferences({...this.props.preferences, currency_settings: currency_settings})
  }

  handleOnChangeDefaultCurrency(e) {
    this.props.handleChangePreferences({...this.props.preferences, default_currency: e.target.value})
  }

  render() {
    let default_currency = this.props.preferences.default_currency || ''
    let currency_settings = this.props.preferences.currency_settings || {}
    let supported_currencies = currency_settings['supported_currencies'] || []
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
              <div>
                <MultiSelect
                  options={this.state.currencyOptions}
                  value={supported_currencies || []}
                  className='supported-currencies'
                  onChange={this.handleOnChangeCurrencies}
                  labelledBy={"Select currency"}
                />
                <ul>
                  {  
                    supported_currencies.map(l => {
                      return <li className='font-size-14' key={l.value}>
                        <i className="icon-check"></i>
                        {l.label}
                      </li>
                    })
                  }
              </ul>
              </div>
            </div>
            <div className='form-control'>
              <label className='font-weight-regular'>Default currency</label>
              <select name='default_currency' value={default_currency || ""} onChange={this.handleOnChangeDefaultCurrency}>
                  { 
                    this.state.currencyOptions.map(option => {
                      return <option value={option.value}>{option.label}</option>
                    })
                  }
              </select>
            </div>
          </div>
        </div>
      </div>
   );
 }
}

export default Currency;