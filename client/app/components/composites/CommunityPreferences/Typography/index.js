import React, { Component } from 'react';
import InputRange from 'react-input-range';
import FontPicker from '../FontPicker/FontPicker';
import HeadingsSetting from './HeadingsSetting'
import ButtonsSetting from './ButtonsSetting'
import MainMenuSetting from './MainMenuSetting'
import SectionHeadingsSetting from './SectionHeadingsSetting'

class Typography extends Component {
  constructor(props) {
    super(props)

    this.handleOnChangeBaseFontSize = this.handleOnChangeBaseFontSize.bind(this)
    this.handleOnChangeButtonsLetterSpacing = this.handleOnChangeButtonsLetterSpacing.bind(this)
    this.handleChangeBodyFontFamily = this.handleChangeBodyFontFamily.bind(this)
  }

  componentDidMount() {
    let body_text_font_settings = this.props.preferences.body_text_font_settings || {}
    if(body_text_font_settings['font_family']) {
      $('#font-picker-bodyTextFont').css('font-family', body_text_font_settings['font_family'])
    }
  }

  handleOnChangeBaseFontSize(value) {
    this.props.handleChangePreferences({
      ...this.props.preferences,
      base_font_size: value
    })
  }

  handleOnChangeButtonsLetterSpacing(value) {
    let button_font_settings = this.props.preferences.button_font_settings || {}
    button_font_settings['letter_spacing'] = value
    this.props.handleChangePreferences({
      ...this.props.preferences,
      button_font_settings: button_font_settings
    })
  }

  handleChangeBodyFontFamily(e) {
    let body_text_font_settings = this.props.preferences.body_text_font_settings || {}
    body_text_font_settings['font_family'] = e.family
    this.props.handleChangePreferences({
      ...this.props.preferences,
      body_text_font_settings: body_text_font_settings
    })
    $('#font-picker-bodyTextFont').css('font-family', e.family)
  }

  render() {
    let base_font_size = this.props.preferences.base_font_size || 16
    let body_text_font_settings = this.props.preferences.body_text_font_settings || {}
    return (
      <div className="section row">
        <label className="m-1">Typography</label>
        <div className="section-wrapper col-8 m-1 row">
          <div className="col-5">
            <label className="mt-1 font-weight-regular">Base font size</label>
            <InputRange
              maxValue={72}
              minValue={14}
              value={base_font_size}
              formatLabel={(value) => `${value} px`}
              onChange={(value) => this.handleOnChangeBaseFontSize(value)} />
            <HeadingsSetting 
              preferences={this.props.preferences}
              handleChangePreferences={this.props.handleChangePreferences} />
            <ButtonsSetting 
              preferences={this.props.preferences}
              handleChangePreferences={this.props.handleChangePreferences} />
          </div>

          <div className="col-5">
            <div className='sub-section p-2 mb-2'>
              <label>BODY TEXT</label>
              <label className='font-weight-regular'>Font</label>
              <FontPicker
                apiKey="AIzaSyD3Th59sA9Qu2P8VUgzh1le91wfHUAnhdg"
                activeFontFamily={body_text_font_settings['font_family']}
                onChange={this.handleChangeBodyFontFamily}
                pickerId='bodyTextFont'/>
            </div>
            <MainMenuSetting 
              preferences={this.props.preferences}
              handleChangePreferences={this.props.handleChangePreferences} />
            <SectionHeadingsSetting
              preferences={this.props.preferences}
              handleChangePreferences={this.props.handleChangePreferences} />
          </div>
        </div>
      </div>
   );
 }
}

export default Typography;