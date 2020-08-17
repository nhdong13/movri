import React, { Component } from 'react'
import axios from 'axios'
import ImageUploader from 'react-images-upload';
import { SketchPicker } from 'react-color';
import { previewUploadImageSrc } from '../../../utils/common';
import {
  sortableHandle,
} from 'react-sortable-hoc';

const DragHandle = sortableHandle(() => <span className='font-size-16'>::</span>);
class SlideItem extends Component {
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
      textColorEnabled: false,
      item: props.item
    }

    this.axiosDefaultParams = {
      authenticity_token: $('input[name ="authenticity_token"]').val()
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
    let item = this.state.item
    item[e.target.name] = e.target.value
    this.setState({
      item: item
    })
  }

  handleSubmitForm(e) {
    e.preventDefault()
    const {item} = this.state
    const formData = new FormData();
    const slide_item = {
      heading: item.heading,
      sub_heading: item.sub_heading,
      background_link: item.background_link,
      text_alignment: item.text_alignment,
      button_label: item.button_label,
      button_link: item.button_link,
      text_color: item.text_color,
    }

    formData.append('authenticity_token', $('input[name ="authenticity_token"]').val())

    for (let key in slide_item) {
      if(slide_item[key]) {
        formData.append(`slide_item[${key}]`, slide_item[key])
      }
    }

    if (item.image) {
      formData.append('slide_item[image]', item.image[0])
    }

    const axiosOptions = {
      url: item.id ? `/admin/slideshows/${item.slideshow_id}/slide_items/${item.id}` :  `/admin/slideshows/${item.slideshow_id}/slide_items`,
      method: item.id ? 'put' : 'post',
      data: formData 
    }
    this.setState({saving: true})
    axios(axiosOptions).then(res => {
      this.props.handleUpdateItems(res.data.slide_item)
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
      <div className='collapsible slideshow-item'>
        <div className='row section-column-header-toggle display-flex align-items-center' onClick={this.handleToggleItem}>
          <div className='col-4 p-0 row m-0 display-flex align-items-center'>
            <div className='col-2 p-0'>
              <i className={`icon-caret-right ${this.state.collapsed ? 'down' : ''}`}></i>
            </div>
            <div className='col-10 p-0'>
              <div className='slide-image-placeholder'>
                <img src={this.state.item.image_url} alt=''></img>
              </div>
            </div>
           
          </div>
          <div className='col-7 p-0 text-truncate'>
            <div className='heading-title font-size-16'>{this.state.item.heading}</div>
          </div>
          <div className='col-1 p-0'>
            <DragHandle />
          </div>
        </div>
        { this.state.collapsed && <div className='collapse-item'>
            <form id='slide-item-form' onSubmit={this.handleSubmitForm}>
              <div className='background-image'>
                <p>Background image</p>
                <p>1800 x 1000px .png recommended</p>
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
                <label>Subheading</label>
                <input name='sub_heading' type='text' value={this.state.item.sub_heading || ''} onChange={this.handleOnChange}/>
              </div>
              <div className='form-control'>
                <button
                  type='button'
                  className='color-box' 
                  style={{backgroundColor: this.state.item.text_color}} 
                  onClick={this.colorPickToggle}>
                </button>
                <label>Text color</label>
                {this.state.textColorEnabled && 
                  <div>
                    <div style={ styles.cover } onClick={ this.handleColorClose }/>
                    <SketchPicker
                      color={ this.state.item.text_color }
                      onChangeComplete={ this.handleTextColorChangeComplete }
                    />
                  </div>
                }
              </div>
              <div className='form-control'>
                <label>Background link</label>
                <input name='background_link' value={this.state.item.background_link || ''} type='text' onChange={this.handleOnChange}></input>
              </div>
              <div className='form-control'>
                <label>Text alignment</label>
                <select name='text_alignment' onChange={this.handleOnChange} defaultValue={this.state.item.text_alignment}>
                  <option value='left' >Left</option>
                  <option value='center' >Center</option>
                  <option value='right'>Right</option>
                </select>
              </div>
              <label>BUTTONS</label>
              <div className='form-control'>
                <label>Button label</label>
                <input name='button_label' value={this.state.item.button_label || ''} type='text' onChange={this.handleOnChange}/>
              </div>
              <div className='form-control'>
                <label>Button link</label>
                <input name='button_link' value={this.state.item.button_link || ''} type='text' onChange={this.handleOnChange}/>
              </div>
              <div className='row'>
                <div className='col-8 p-0'>
                  <button className='p-2 btn' type='button' onClick={() => this.props.handleRemoveItem(this.state.item)}>{ this.state.removing ? 'Removing...' : 'Remove content'}</button>
                </div>
                <div className='col-4 p-0'>
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

SlideItem.defaultProps = {
  item: {}
}

export default SlideItem