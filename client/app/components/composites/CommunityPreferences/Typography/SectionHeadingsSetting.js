import React, { Component } from 'react';
import InputRange from 'react-input-range';
import FontPicker from '../FontPicker/FontPicker';

class SectionHeadingsSetting extends Component {
  constructor(props) {
    super(props)
    this.handleChangeSectionHeadingsSetting = this.handleChangeSectionHeadingsSetting.bind(this)
    this.handleChangeFontFamily = this.handleChangeFontFamily.bind(this)
    this.handleOnChangeLetterSpacing = this.handleOnChangeLetterSpacing.bind(this)
  }

  componentDidMount() {
    let section_heading_font_settings = this.props.preferences.section_heading_font_settings || {}
    if(section_heading_font_settings['font_family']) {
      $('#font-picker-sectionHeadingsFont').css('font-family', section_heading_font_settings['font_family'])
    }
  }

  handleChangeSectionHeadingsSetting(e) {
    let section_heading_font_settings = this.props.preferences.section_heading_font_settings || {}
    if(e.target.name == 'uppercase') {
      section_heading_font_settings[e.target.name] = !section_heading_font_settings[e.target.name]
    } else {
      section_heading_font_settings[e.target.name] = e.target.value
    }
    this.props.handleChangePreferences({
      ...this.props.preferences,
      section_heading_font_settings: section_heading_font_settings
    })
  }

  handleChangeFontFamily(e) {
    let section_heading_font_settings = this.props.preferences.section_heading_font_settings || {}
    section_heading_font_settings["font_family"] = e.family
    this.props.handleChangePreferences({
      ...this.props.preferences,
      section_heading_font_settings: section_heading_font_settings
    })
    $('#font-picker-sectionHeadingsFont').css('font-family', e.family)
  }

  handleOnChangeLetterSpacing(value) {
    let section_heading_font_settings = this.props.preferences.section_heading_font_settings || {}
    section_heading_font_settings["letter_spacing"] = value
    this.props.handleChangePreferences({
      ...this.props.preferences,
      section_heading_font_settings: section_heading_font_settings
    })
  }

  render() {
    let section_heading_font_settings = this.props.preferences.section_heading_font_settings || {}
    return (
      <div className='sub-section p-2 mb-2'>
        <label>SECTION HEADINGS</label>
        <label className='font-weight-regular'>Font</label>
        <FontPicker
          apiKey="AIzaSyD3Th59sA9Qu2P8VUgzh1le91wfHUAnhdg"
          activeFontFamily={section_heading_font_settings['font_family']}
          onChange={this.handleChangeFontFamily}
          pickerId='sectionHeadingsFont' />
        <div className='display-flex align-items-center mt-2'>
          <input type='checkbox' name='uppercase' className='mr-2' checked={section_heading_font_settings['uppercase'] || false} onChange={this.handleChangeSectionHeadingsSetting}/>
          <label className='font-weight-regular m-0'>Uppercase</label>
        </div>
        <label className='font-weight-regular'>Letter spacing</label>
        <InputRange
          maxValue={100}
          minValue={0}
          value={section_heading_font_settings["letter_spacing"] || 0}
          formatLabel={(value) => `${value} %`}
          onChange={(value) => this.handleOnChangeLetterSpacing(value)}/>
      </div>
    );
  }
}

export default SectionHeadingsSetting;