import React, { Component } from 'react'
import axios from 'axios'
import ImageUploader from 'react-images-upload'
import { previewUploadImageSrc } from '../../../utils/common'
import SimpleCkeditor from '../../elements/SimpleCkeditor'


class BannerItem extends Component {
  constructor(props) {
    super(props)
    this.handleOnChange = this.handleOnChange.bind(this)
    this.handleSubmitForm = this.handleSubmitForm.bind(this)
    this.handleTextColorChangeComplete = this.handleTextColorChangeComplete.bind(this)
    this.handleColorClose = this.handleColorClose.bind(this)
    this.colorPickToggle = this.colorPickToggle.bind(this)
    this.handleToggleItem = this.handleToggleItem.bind(this)
    this.onloadCallback = this.onloadCallback.bind(this)
    this.onDrop = this.onDrop.bind(this)
    
    this.state = {
      saving: false,
      removing: false,
      collapsed: false,
      item: props.item
    }

    this.axiosDefaultParams = {
      authenticity_token: $('input[name ="authenticity_token"]').val()
    }

  }

  componentWillReceiveProps(nextProps ) {
    if (nextProps.item !== this.state.item) {
      this.setState({
        item: nextProps.item
      })
    }
  }

  handleToggleItem() {
    this.setState({
      collapsed: !this.state.collapsed
    })
  }

  handleColorClose() {
    this.setState({textColorEnabled: false})
  }

  colorPickToggle() {
    this.setState({textColorEnabled: !this.state.textColorEnabled})
  }

  handleTextColorChangeComplete(color) {
    this.setState({
      item: {
        ...this.state.item,
        text_color: color.hex
      }
    })
  }

  handleOnChange(e) {
    this.setState({
      item: {
        ...this.state.item,
        [e.target.name]: e.target.value
      }
    })
  }

  handleSubmitForm(e) {
    e.preventDefault()
    const {item} = this.state
    const formData = new FormData();
    const banner_item = {
      heading: item.heading,
      sub_heading: item.sub_heading,
      link: item.link,
      text: item.text,
    }

    formData.append('authenticity_token', $('input[name ="authenticity_token"]').val())

    for (let key in banner_item) {
      formData.append(`banner_item[${key}]`, banner_item[key])
    }

    if (item.image) {
      formData.append('banner_item[image]', item.image[0])
    }

    const axiosOptions = {
      url: item.id ? `/admin/highlight_banners/${item.highlight_banner_id}/banner_items/${item.id}` :  `/admin/highlight_banners/${item.highlight_banner_id}/banner_items`,
      method: item.id ? 'put' : 'post',
      data: formData 
    }
    this.setState({saving: true})
    axios(axiosOptions).then(res => {
      this.setState({
        saving: false,
        collapsed: false,
        // item: res.data.banner_item
      })
      this.props.handleUpdateNewItem(item.id, res.data.banner_item)
      $("#homepage-preview-iframe").attr("src", function(index, attr){ 
        return attr;
      });
    })
  }

  onloadCallback(src){
    this.setState({
      item: {
        ...this.state.item,
        image_url: src
      }
    })
  }

  onDrop(image) {
    previewUploadImageSrc(image, this.onloadCallback)
    this.setState({
      item: {
        ...this.state.item,
        image: image
      }
    })
  }

  render() {
    return (
      <div className='collapsible slideshow-item'>
        <div className='row section-column-header-toggle' onClick={this.handleToggleItem}>
          <i className={`icon-caret-right ${this.state.collapsed ? 'down' : ''}`}></i>
          <div className='slide-image-placeholder banner-item'>
            <img src={this.state.item.image_url} alt=''></img>
          </div>
          <div className='heading-title'>{this.state.item.heading}</div>
        </div>
        { this.state.collapsed && <div className='collapse-item'>
            <form id='slide-item-form' onSubmit={this.handleSubmitForm}>
              <div className='background-image'>
                <p>Image</p>
                <img src={this.state.item.image_url} alt='item-image' />
                <ImageUploader
                  className='logo-uploader'
                  withLabel={false}
                  withIcon={false}
                  buttonText='Choose images'
                  onChange={this.onDrop}
                  imgExtension={['.jpg', '.gif', '.png', '.gif']}
                  maxFileSize={5242880}
                  name='image'
                  singleImage={true}
                />
              </div>
              <div className='form-control'>
                <label>Heading</label>
                <input name='heading' value={this.state.item.heading || ''} type='text' onChange={this.handleOnChange}/>
              </div>
              <div className='form-control'>
                <label>Sub heading</label>
                <input name='sub_heading' type='text' value={this.state.item.sub_heading || ''} onChange={this.handleOnChange}/>
              </div>
              <div className='form-control'>
                <label>Text</label>
                <SimpleCkeditor 
                  name='text'
                  value={this.state.item.text || ''}
                  id={this.state.item.id}
                  handleOnChange={this.handleOnChange}
                />
              </div>
              <div className='form-control'>
                <label>Link</label>
                <input name='link' value={this.state.item.link || ''} type='text' onChange={this.handleOnChange} placeholder='Paste a link or search'></input>
              </div>
              <div className='row'>
                <div className='col-8'>
                  <button className='p-2 btn' type='button' onClick={() => this.props.handleRemoveItem(this.state.item)}>{ this.state.removing ? 'Removing...' : 'Remove content'}</button>
                </div>
                <div className='col-4'>
                  <button className='p-2 btn' type='submit'>{ this.state.saving ? 'Saving' : 'Save' }</button>
                </div>
              </div>
            </form>
          </div>
        }
      </div>
    )
  }
}

export default BannerItem