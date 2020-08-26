import React, { Component } from 'react'
import { SketchPicker } from 'react-color';
import './style.css'

class Phone extends Component {
  constructor(props) {
    super(props)
    this.handleFormOnChange = this.handleFormOnChange.bind(this)
    this.colorPickToggle  = this.colorPickToggle.bind(this)
    this.bgPickToggle     = this.bgPickToggle.bind(this)
    this.handleTextColorChangeComplete = this.handleTextColorChangeComplete.bind(this)
    this.handleBgColorChangeComplete  = this.handleBgColorChangeComplete.bind(this)
    this.handleClose = this.handleClose.bind(this)

    this.state = {
      textColorEnabled: false,
      bgColorEnabled: false,
      imageUploading: false
    }
  }

  handleFormOnChange(e) {
    let phoneNumberSetting = {...this.props.object} || {}
    let value = e.target.value
    if (e.target.type === 'checkbox') {
      value = e.target.checked
    }
    phoneNumberSetting[e.target.name] = value
    this.props.handleChangePhoneSetting(phoneNumberSetting)
  }

  handleClose() {
    this.setState({
      textColorEnabled: false,
      bgColorEnabled: false
    })
  }

  colorPickToggle() {
    this.setState({textColorEnabled: !this.state.textColorEnabled})
  }

  bgPickToggle() {
    this.setState({bgColorEnabled: !this.state.bgColorEnabled})
  }

  handleTextColorChangeComplete(color) {
    let phoneNumberSetting = {...this.props.object} || {}
    phoneNumberSetting['text_color'] = color.hex
    this.props.handleChangePhoneSetting(phoneNumberSetting)
  }

  handleBgColorChangeComplete(color) {
    let phoneNumberSetting = {...this.props.object} || {}
    phoneNumberSetting['background_color'] = color.hex
    this.props.handleChangePhoneSetting(phoneNumberSetting)
  }

  render() {
    const styles = {
      cover: {
        position: 'fixed',
        top: '0px',
        right: '0px',
        bottom: '0px',
        left: '0px',
      }
    }

    let phoneNumberSetting = {...this.props.object} || {}

    return (
      <div>
        <label>PHONE NO.</label>
        <div className='form-control'>
          <input
            name='phone_number'
            type='text'
            value={phoneNumberSetting['phone_number'] || ''}
            onChange={this.handleFormOnChange}/>
        </div>
        <div className='form-control'>
          <label className='font-weight-regular'>Link</label>
          <input
            name='link'
            type='text'
            value={phoneNumberSetting['link'] || ''}
            onChange={this.handleFormOnChange}/>
        </div>
        <div>
          <button
            type='button'
            className='color-box' 
            style={{backgroundColor: phoneNumberSetting['text_color'] || '#000000'}} 
            onClick={this.colorPickToggle}>
          </button>
          <label className='font-weight-regular'>Text color</label>
          {this.state.textColorEnabled && 
            <div>
              <div style={ styles.cover } onClick={ this.handleClose }/>
              <SketchPicker
                color={phoneNumberSetting['text_color'] || '#000000'}
                onChangeComplete={ this.handleTextColorChangeComplete }
              />
            </div>}
        </div>
        <div>
          <button
            type='button'
            className='color-box' 
            style={{backgroundColor: phoneNumberSetting['background_color'] || '#FFFFFF'}} 
            onClick={this.bgPickToggle}>
          </button>
          <label className='font-weight-regular'>Background color</label>
          {this.state.bgColorEnabled && 
            <div>
              <div style={ styles.cover } onClick={ this.handleClose }/>
              <SketchPicker
                color={phoneNumberSetting['background_color'] || '#FFFFFF'}
                onChangeComplete={ this.handleBgColorChangeComplete }
              />
            </div>}
        </div>
      </div>
    )
  }
}

Phone.defaultProps = {
  object: {
    logo_url: 'images/missing_image.png'
  }
}

export default Phone