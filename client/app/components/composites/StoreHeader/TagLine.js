import React, { Component } from 'react'
import { SketchPicker } from 'react-color';
import './style.css'
import SimpleCkeditor from '../../elements/SimpleCkeditor'

class TagLine extends Component {
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
    let tagLineSetting = {...this.props.object} || {}
    let value = e.target.value
    if (e.target.type === 'checkbox') {
      value = e.target.checked
    }
    tagLineSetting[e.target.name] = value
    this.props.handleChangeTagLineSetting(tagLineSetting)
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
    let tagLineSetting = {...this.props.object} || {}
    tagLineSetting['text_color'] = color.hex
    this.props.handleChangeTagLineSetting(tagLineSetting)
  }

  handleBgColorChangeComplete(color) {
    let tagLineSetting = {...this.props.object} || {}
    tagLineSetting['background_color'] = color.hex
    this.props.handleChangeTagLineSetting(tagLineSetting)
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

    let tagLineSetting = {...this.props.object} || {}

    return (
      <div>
        <label>TAG LINE</label>
        <div className='checkbox-control'>
          <input
            className='checkbox-input'
            name='enabled'
            type='checkbox'
            checked={tagLineSetting['enabled'] || false}
            onChange={this.handleFormOnChange}
            id='tag_line_enabled' />
          <label className='checkbox-label' htmlFor='tag_line_enabled'>Show tag line</label>
        </div>
        <div className='checkbox-control'>
          <input
            className='checkbox-input'
            name='home_only_enabled'
            type='checkbox'
            checked={tagLineSetting['home_only_enabled'] || false}
            onChange={this.handleFormOnChange}
            id='tag_line_home_only_enabled' />
          <label className='checkbox-label' htmlFor='tag_line_home_only_enabled'>Show on home page only</label>
        </div>
        <div className='form-control'>
          <label className='font-weight-regular'>Text</label>
          <SimpleCkeditor 
            name='text'
            value={tagLineSetting['text'] || ''}
            id={`tag_line_text`}
            handleOnChange={this.handleFormOnChange}
          />
        </div>
        <div className='form-control'>
          <label className='font-weight-regular'>Link</label>
          <input
            name='link'
            type='text'
            value={tagLineSetting['link'] || ''}
            onChange={this.handleFormOnChange}/>
        </div>
        <div>
          <button
            type='button'
            className='color-box' 
            style={{backgroundColor: tagLineSetting['text_color'] || '#000000'}} 
            onClick={this.colorPickToggle}>
          </button>
          <label className='font-weight-regular'>Text color</label>
          {this.state.textColorEnabled && 
            <div>
              <div style={ styles.cover } onClick={ this.handleClose }/>
              <SketchPicker
                color={tagLineSetting['text_color'] || '#000000'}
                onChangeComplete={ this.handleTextColorChangeComplete }
              />
            </div>}
        </div>
        <div>
          <button
            type='button'
            className='color-box' 
            style={{backgroundColor: tagLineSetting['background_color'] || '#000000'}} 
            onClick={this.bgPickToggle}>
          </button>
          <label className='font-weight-regular'>Background color</label>
          {this.state.bgColorEnabled && 
            <div>
              <div style={ styles.cover } onClick={ this.handleClose }/>
              <SketchPicker
                color={tagLineSetting['background_color'] || '#000000'}
                onChangeComplete={ this.handleBgColorChangeComplete }
              />
            </div>}
        </div>
      </div>
    )
  }
}

TagLine.defaultProps = {
  object: {
    logo_url: 'images/missing_image.png'
  }
}

export default TagLine