import React, { Component } from 'react';
import axios from 'axios'
import Color from './Color'
import SocialMedia from './SocialMedia'
import Favicon from './Favicon'
import Currency from './Currency'
import Typography from './Typography/index'

class CommunityPreferences extends Component {
  constructor(props) {
    super(props)
    let preferences = props.preferences && props.preferences.id ? props.preferences : {}
    this.state = {
      preferences: preferences
    }
    this.handleChangeForm = this.handleChangeForm.bind(this)
    this.handleChangePreferences = this.handleChangePreferences.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
  }

  handleChangeForm(e) {
    let preferences = this.state.preferences || {}
    preferences[e.target.name] = e.target.value
    this.setState({
      preferences: preferences
    })
  }

  handleChangePreferences(preferences) {
    this.setState({
      preferences: preferences
    })
  }

  handleSubmit(e) {
    e.preventDefault()
    let preferences = this.state.preferences || {}
    let formData = new FormData();
    formData.append('authenticity_token', $('input[name ="authenticity_token"]').val())

    let preferences_params = {
      id: preferences.id,
      community_id: preferences.community_id,
      facebook_pixel_id: preferences.facebook_pixel_id,
      default_currency: preferences.default_currency,
      base_font_size: preferences.base_font_size,
      general_colors: JSON.stringify(preferences.general_colors),
      button_colors: JSON.stringify(preferences.button_colors),
      footer_colors: JSON.stringify(preferences.footer_colors),
      header_colors: JSON.stringify(preferences.header_colors),
      heading_font_settings: JSON.stringify(preferences.heading_font_settings),
      button_font_settings: JSON.stringify(preferences.button_font_settings),
      main_menu_font_settings: JSON.stringify(preferences.main_menu_font_settings),
      section_heading_font_settings: JSON.stringify(preferences.section_heading_font_settings),
      social_media_accounts: JSON.stringify(preferences.social_media_accounts),
      currency_settings: JSON.stringify(preferences.currency_settings),
      body_text_font_settings: JSON.stringify(preferences.body_text_font_settings),
    }

    for (let key in preferences_params) {
      formData.append(`preferences[${key}]`, preferences_params[key])
    }

    if (preferences.social_media_image) {
      formData.append('preferences[social_media_image]', preferences.social_media_image[0])
    }

    if (preferences.favicon_icon) {
      formData.append('preferences[favicon_icon]', preferences.favicon_icon[0])
    }

    const axiosOptions = {
      url: `/admin/communities/${this.state.preferences.community_id}/preferences`,
      method: 'put',
      data: formData
    }

    axios(axiosOptions).then(res => {
      window.location.reload()
    })
  }

  render() {
    let preferences = this.state.preferences || {}
    return (
      <div className="community-preferences">
        <div className="section row">
          <label className="m-1">Facebook Pixel</label>
          <div className="section-wrapper col-8 m-1">
            <div className='form-control'>
              <label className='font-weight-regular m-0 mb-1'>Facebook Pixel ID</label>
              <input name="facebook_pixel_id"
                     type='number'
                     className="text_field"
                     value={preferences.facebook_pixel_id || ""}
                     onChange={this.handleChangeForm}
              />
            </div>
          </div>
        </div>
        <Color
          preferences={preferences} 
          handleChangePreferences={this.handleChangePreferences} />
        <Typography
          preferences={preferences}
          handleChangePreferences={this.handleChangePreferences} />
        <SocialMedia
          preferences={preferences}
          handleChangePreferences={this.handleChangePreferences} />
        <Currency
          preferences={preferences}
          handleChangePreferences={this.handleChangePreferences} />
        <div className='row m-0 display-flex p-0 justify-content-end'>
          <div className='col-2 p-0 m-0'>
            <button className='p-2 btn btn-primary w-100' onClick={this.handleSubmit}>Save</button>
          </div>
        </div>
      </div>
   );
 }
}

export default CommunityPreferences;