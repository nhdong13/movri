import React, { Component } from 'react';
import InputRange from 'react-input-range';
import FontPicker from '../FontPicker/FontPicker';

class HeadingsSetting extends Component {
  constructor(props) {
    super(props)
    this.handleOnChangeHeadingsLetterSpacing = this.handleOnChangeHeadingsLetterSpacing.bind(this)
    this.handleChangeHeadingsFont = this.handleChangeHeadingsFont.bind(this)
    this.handleChangeHeadingsSetting = this.handleChangeHeadingsSetting.bind(this)
  }

  handleOnChangeHeadingsLetterSpacing(value) {
    let heading_font_settings = this.props.preferences.heading_font_settings || {}
    heading_font_settings['letter_spacing'] = value
    this.props.handleChangePreferences({
      ...this.props.preferences,
      heading_font_settings: heading_font_settings
    })
  }

  handleChangeHeadingsSetting(e) {
    let heading_font_settings = this.props.preferences.heading_font_settings || {}
    if(e.target.name == 'uppercase') {
      heading_font_settings[e.target.name] = !heading_font_settings[e.target.name]
    } else {
      heading_font_settings[e.target.name] = e.target.value
    }
    this.props.handleChangePreferences({
      ...this.props.preferences,
      heading_font_settings: heading_font_settings
    })
  }

  handleChangeHeadingsFont(e) {
    let heading_font_settings = this.props.preferences.heading_font_settings || {}
    heading_font_settings['font_family'] = e.family
    this.props.handleChangePreferences({
      ...this.props.preferences,
      heading_font_settings: heading_font_settings
    })
  }

  render() {
    let heading_font_settings = this.props.preferences.heading_font_settings || {}
    return (
      <div className='sub-section p-2 mb-2'>
        <label>HEADINGS</label>
        <label className='font-weight-regular'>Font</label>
        <FontPicker
          apiKey="AIzaSyD3Th59sA9Qu2P8VUgzh1le91wfHUAnhdg"
          activeFontFamily={heading_font_settings['font_family']}
          onChange={this.handleChangeHeadingsFont}/>
        <label className='font-weight-regular'>Size</label>
        <select name='font_weight' value={heading_font_settings['font_weight'] || 'medium'} onChange={this.handleChangeHeadingsSetting}>
          <option value='small'>Small</option>
          <option value='medium'>Medium</option>
          <option value='large'>Large</option>
        </select>
        <div className='font-size-14 text-gray'>All headings size will be adjusted</div>
        <div className='display-flex align-items-center mt-2'>
          <input type='checkbox' name='uppercase' className='mr-2' checked={heading_font_settings['uppercase'] || false} onChange={this.handleChangeHeadingsSetting}/>
          <label className='font-weight-regular m-0'>Uppercase</label>
        </div>
        <label className='font-weight-regular'>Letter spacing</label>
        <InputRange
          maxValue={100}
          minValue={0}
          value={heading_font_settings["letter_spacing"] || 0}
          name="letter_spacing"
          formatLabel={(value) => `${value} %`}
          onChange={(value) => this.handleOnChangeHeadingsLetterSpacing(value)}/>
      </div>
    );
  }
}

export default HeadingsSetting;