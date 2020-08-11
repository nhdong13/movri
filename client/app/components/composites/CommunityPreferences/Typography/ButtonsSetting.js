import React, { Component } from 'react';
import InputRange from 'react-input-range';
import FontPicker from '../FontPicker/FontPicker';

class ButtonsSetting extends Component {
  constructor(props) {
    super(props)
    this.handleChangeButtonsSetting = this.handleChangeButtonsSetting.bind(this)
    this.handleChangeFontFamily = this.handleChangeFontFamily.bind(this)
    this.handleOnChangeLetterSpacing = this.handleOnChangeLetterSpacing.bind(this)
  }

  handleChangeButtonsSetting(e) {
    let button_font_settings = this.props.preferences.button_font_settings || {}
    if(e.target.name == 'uppercase') {
      button_font_settings[e.target.name] = !button_font_settings[e.target.name]
    } else {
      button_font_settings[e.target.name] = e.target.value
    }
    this.props.handleChangePreferences({
      ...this.props.preferences,
      button_font_settings: button_font_settings
    })
  }

  handleChangeFontFamily(e) {
    let button_font_settings = this.props.preferences.button_font_settings || {}
    button_font_settings["font_family"] = e.family
    this.props.handleChangePreferences({
      ...this.props.preferences,
      button_font_settings: button_font_settings
    })
  }

  handleOnChangeLetterSpacing(value) {
    let button_font_settings = this.props.preferences.button_font_settings || {}
    button_font_settings["letter_spacing"] = value
    this.props.handleChangePreferences({
      ...this.props.preferences,
      button_font_settings: button_font_settings
    })
  }

  render() {
    let button_font_settings = this.props.preferences.button_font_settings || {}
    return (
      <div className='sub-section p-2'>
        <label>BUTTONS</label>
        <label className='font-weight-regular'>Font</label>
        <FontPicker
          apiKey="AIzaSyD3Th59sA9Qu2P8VUgzh1le91wfHUAnhdg" 
          activeFontFamily={button_font_settings['font_family']}
          onChange={this.handleChangeFontFamily} />
        <div className='display-flex align-items-center mt-2'>
          <input type='checkbox' name='uppercase' className='mr-2' checked={button_font_settings['uppercase'] || false} onChange={this.handleChangeButtonsSetting}/>
          <label className='font-weight-regular m-0'>Uppercase</label>
        </div>
        <label className='font-weight-regular'>Letter spacing</label>
        <InputRange
          maxValue={100}
          minValue={0}
          value={button_font_settings["letter_spacing"] || 0}
          formatLabel={(value) => `${value} %`}
          onChange={(value) => this.handleOnChangeLetterSpacing(value)}/>
      </div>
    );
  }
}

export default ButtonsSetting;