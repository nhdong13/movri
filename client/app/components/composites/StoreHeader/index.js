import React, { Component } from 'react'
import { SketchPicker } from 'react-color';
import axios from 'axios'
import ImageUploader from 'react-images-upload';
import './style.css'
import { previewUploadImageSrc } from '../../../utils/common';

class StoreHeader extends Component {
  constructor(props) {
    super(props)
    this.handleFormOnChange = this.handleFormOnChange.bind(this)
    this.handleSubmitForm = this.handleSubmitForm.bind(this)
    this.colorPickToggle  = this.colorPickToggle.bind(this)
    this.bgPickToggle     = this.bgPickToggle.bind(this)
    this.handleTextColorChangeComplete = this.handleTextColorChangeComplete.bind(this)
    this.handleBgColorChangeComplete  = this.handleBgColorChangeComplete.bind(this)
    this.handleClose = this.handleClose.bind(this)
    this.onloadCallback = this.onloadCallback.bind(this)
    this.onDrop = this.onDrop.bind(this)

    this.axiosDefaultParams = {
      authenticity_token: $('input[name ="authenticity_token"]').val()
    }

    this.state = {
      textColorEnabled: false,
      bgColorEnabled: false,
      object: props.object,
      imageUploading: false
    }
  }

  componentDidMount() {
    axios.defaults.headers = {
      'Content-Type': 'application/json'
    }
  }

  handleFormOnChange(e) {
    let value = e.target.value
    if (e.target.type === 'checkbox') {
      value = e.target.checked
    }
    this.setState({
      object: {...this.state.object, [e.target.name]: value}
    })
  }

  handleSubmitForm(e) {
    e.preventDefault()
    const store_header = {
      sticky_enabled: this.state.object.sticky_enabled,
      announcement_enabled: this.state.object.announcement_enabled,
      home_only_enabled: this.state.object.home_only_enabled,
      title: this.state.object.title,
      link: this.state.object.link,
      text_color: this.state.object.text_color,
      background_color: this.state.object.background_color
    }

    const params = {...this.axiosDefaultParams, store_header}
    this.setState({loading: true})
    axios.put(`/admin/store_headers/${this.state.object.id}`, params).then(res => {
      this.setState({loading: false})
      $("#homepage-preview-iframe").attr("src", function(index, attr){ 
        return attr;
      });
    })
  }

  handleClose() {
    this.setState({
      textColorEnabled: false,
      bgColorEnabled: false
    })
  }

  onloadCallback(src){
    this.setState({
      object: {
        ...this.state.item,
        logo_url: src
      }
    })
  }

  onDrop(image) {
    previewUploadImageSrc(image, this.onloadCallback)
    const formData = new FormData()
    formData.append('authenticity_token', $('input[name ="authenticity_token"]').val())
    formData.append('logo', image[0])

    axios.post(`/admin/store_headers/${this.state.object.id}/upload_logo`, formData).then(res => {
      this.setState({
        object: {
          ...this.state.object,
          logo_url: res.data.logo_url
        }
      })
      $("#homepage-preview-iframe").attr("src", function(index, attr){ 
        return attr;
      });
    })
  }


  colorPickToggle() {
    this.setState({textColorEnabled: !this.state.textColorEnabled})
  }

  bgPickToggle() {
    this.setState({bgColorEnabled: !this.state.bgColorEnabled})
  }

  handleTextColorChangeComplete(color) {
    this.setState({
      object: {...this.state.object, text_color: color.hex}
    })
  }

  handleBgColorChangeComplete(color) {
    this.setState({
      object: {...this.state.object, background_color: color.hex}
    })
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

      
    return (
      <div className='store-header'>
        <div className='breabcrum' onClick={() => this.props.toggleActiveSub('')}>
          <i className="icon-chevron-left"></i>
          <span>Header</span>
        </div>
        <h1 className=''>Settings</h1>
        <div className='main-form-content'>
          <form onSubmit={this.handleSubmitForm}>
            <div className='checkbox-control'>
              <input 
                className='checkbox-input' 
                name='sticky_enabled' 
                type='checkbox'
                checked={this.state.object.sticky_enabled}
                onChange={this.handleFormOnChange}
                id='sticky_enabled' />
              <label htmlFor='sticky_enabled' className='checkbox-label'>Enable sticky header</label>
            </div>
            <div className='logo-image'>
              <p>Logo image</p>
              <p>200 x 80px .png recommended</p>
              <div className=''>
                <img src={this.state.object.logo_url} alt='logo-image' />
                <ImageUploader
                  className='logo-uploader'
                  withLabel={false}
                  withIcon={false}
                  buttonText='Choose images'
                  onChange={this.onDrop}
                  imgExtension={['.jpg', '.gif', '.png', '.gif']}
                  maxFileSize={5242880}
                  singleImage={true}
                />
              </div>
              <div className=''>
                <label>ANNOUNCEMENT BAR</label>
                <div className='checkbox-control'>
                  <input 
                    className='checkbox-input'
                    name='announcement_enabled'
                    type='checkbox'
                    checked={this.state.object.announcement_enabled}
                    onChange={this.handleFormOnChange}
                    id='announcement_enabled' />
                  <label className='checkbox-label' htmlFor='announcement_enabled'>Show announcement</label>
                </div>
                <div className='checkbox-control'>
                  <input
                    className='checkbox-input'
                    name='home_only_enabled'
                    type='checkbox'
                    checked={this.state.object.home_only_enabled}
                    onChange={this.handleFormOnChange}
                    id='home_only_enabled' />
                  <label className='checkbox-label' htmlFor='home_only_enabled'>Show on Homepage only</label>
                </div>
              </div>
              <div className=''>
                <label>Text</label>
                <textarea name='title' value={this.state.object.title} onChange={ this.handleFormOnChange }></textarea>
              </div>
              <div className=''>
                <label>Link</label>
                <textarea name='link' value={this.state.object.link} onChange={ this.handleFormOnChange }></textarea>
              </div>
              <div>
                <button
                  type='button'
                  className='color-box' 
                  style={{backgroundColor: this.state.object.text_color}} 
                  onClick={this.colorPickToggle}>
                </button>
                <label>Text color</label>
                {this.state.textColorEnabled && 
                  <div>
                    <div style={ styles.cover } onClick={ this.handleClose }/>
                    <SketchPicker
                      color={ this.state.object.text_color }
                      onChangeComplete={ this.handleTextColorChangeComplete }
                    />
                  </div>}
              </div>
              <div>
                <button 
                  type='button'
                  className='color-box' 
                  style={{backgroundColor: this.state.object.background_color}}  
                  onClick={this.bgPickToggle}>
                </button>
                <label>Background color</label>
                {this.state.bgColorEnabled && 
                  <div>
                    <div style={ styles.cover } onClick={ this.handleClose }/>
                    <SketchPicker 
                    color={ this.state.object.background_color }
                    onChangeComplete={ this.handleBgColorChangeComplete }
                  />
                </div>}
              </div>
            </div>
                <button className='btn' type='submit'>{ this.state.loading ? 'Saving...' : 'Save' }</button>
          </form>
        </div>
      </div>
    )
  }
}

StoreHeader.defaultProps = {
  object: {
    logo_url: 'images/missing_image.png'
  }
}

export default StoreHeader