import React, { Component } from 'react'
import { SketchPicker } from 'react-color';
import './style.css'
import SimpleCkeditor from '../../elements/SimpleCkeditor'

class Faq extends Component {
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
    let faqSetting = {...this.props.object} || {}
    let value = e.target.value
    if (e.target.type === 'checkbox') {
      value = e.target.checked
    }
    faqSetting[e.target.name] = value
    this.props.handleChangeFaqSetting(faqSetting)
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
    let faqSetting = {...this.props.object} || {}
    faqSetting['text_color'] = color.hex
    this.props.handleChangeFaqSetting(faqSetting)
  }

  handleBgColorChangeComplete(color) {
    let faqSetting = {...this.props.object} || {}
    faqSetting['background_color'] = color.hex
    this.props.handleChangeFaqSetting(faqSetting)
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

    let faqSetting = {...this.props.object} || {}

    return (
      <div>
        <label>FAQ</label>
        <div className='form-control'>
          <label className='font-weight-regular'>Text</label>
          <SimpleCkeditor 
            name='text'
            value={faqSetting['text'] || ''}
            id={`faq_text`}
            handleOnChange={this.handleFormOnChange}
          />
        </div>
        <div className='form-control'>
          <label className='font-weight-regular'>Link</label>
          <input
            name='link'
            type='text'
            value={faqSetting['link'] || ''}
            onChange={this.handleFormOnChange}/>
        </div>
        <div>
          <button
            type='button'
            className='color-box' 
            style={{backgroundColor: faqSetting['text_color'] || '#000000'}} 
            onClick={this.colorPickToggle}>
          </button>
          <label className='font-weight-regular'>Text color</label>
          {this.state.textColorEnabled && 
            <div>
              <div style={ styles.cover } onClick={ this.handleClose }/>
              <SketchPicker
                color={faqSetting['text_color'] || '#000000'}
                onChangeComplete={ this.handleTextColorChangeComplete }
              />
            </div>}
        </div>
        <div>
          <button
            type='button'
            className='color-box' 
            style={{backgroundColor: faqSetting['background_color'] || '#FFFFFF'}} 
            onClick={this.bgPickToggle}>
          </button>
          <label className='font-weight-regular'>Background color</label>
          {this.state.bgColorEnabled && 
            <div>
              <div style={ styles.cover } onClick={ this.handleClose }/>
              <SketchPicker
                color={faqSetting['background_color'] || '#FFFFFF'}
                onChangeComplete={ this.handleBgColorChangeComplete }
              />
            </div>}
        </div>
      </div>
    )
  }
}

Faq.defaultProps = {
  object: {
    logo_url: 'images/missing_image.png'
  }
}

export default Faq