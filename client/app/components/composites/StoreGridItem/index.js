import React, { Component } from  'react'
import ImageUploader from 'react-images-upload';
import axios from 'axios'
import { previewUploadImageSrc } from '../../../utils/common'
import { SketchPicker } from 'react-color'
import SimpleCkeditor from '../../elements/SimpleCkeditor'

class StoreGridItem extends Component {
  constructor(props) {
    super(props)
    this.handleToggleItem = this.handleToggleItem.bind(this)
    this.handleOnChange = this.handleOnChange.bind(this)
    this.handleSubmitForm = this.handleSubmitForm.bind(this)
    this.onDrop = this.onDrop.bind(this)
    this.onloadCallback = this.onloadCallback.bind(this)
    this.handleColorClose = this.handleColorClose.bind(this)
    this.colorPickToggle = this.colorPickToggle.bind(this)
    this.handleTextColorChangeComplete = this.handleTextColorChangeComplete.bind(this)

    this.state = {
      saving: false,
      removing: false,
      collapsed: false,
      textColorEnabled: false,
      item: props.item
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
    let store_grid_item = {
      heading: item.heading,
      text: item.text,
      text_color: item.text_color,
      link: item.link,
      button_text: item.button_text,
      button_style: item.button_style,
      width: item.width
    }

    formData.append('authenticity_token', $('input[name ="authenticity_token"]').val())

    for (let key in store_grid_item) {
      formData.append(`store_grid_item[${key}]`, store_grid_item[key])
    }

    if (item.image) {
      formData.append('store_grid_item[image]', item.image[0])
    }

    const axiosOptions = {
      url: item.id ? `/admin/store_grids/${item.store_grid_id}/store_grid_items/${item.id}` :  `/admin/store_grids/${item.store_grid_id}/store_grid_items`,
      method: item.id ? 'put' : 'post',
      data: formData 
    }
    this.setState({saving: true})
    axios(axiosOptions).then(res => {
      this.setState({
        saving: false,
        collapsed: false,
      })
      this.props.handleUpdateNewItem(item.id, res.data.store_grid_item)
      $("#homepage-preview-iframe").attr("src", function(index, attr){ 
        return attr;
      });
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

  onloadCallback(src) {
    this.setState({
      item: {
        ...this.state.item,
        image_url: src
      }
    })
  }

  handleColorClose() {
    this.setState({ textColorEnabled: false })
  }

  colorPickToggle() {
    this.setState({ textColorEnabled: !this.state.textColorEnabled })
  }

  handleTextColorChangeComplete(color) {
    this.setState({
      item: {
        ...this.state.item,
        text_color: color.hex
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

    const { widths } = JSConstant.SECTION_GRID_OPTIONS

    return(
      <div className='collapsible store-category-item slideshow-item'>
        <div className='row section-column-header-toggle' onClick={this.handleToggleItem}>
          <i className={`icon-caret-right ${this.state.collapsed ? 'down' : ''}`}></i>
          <div className='heading-title'>{this.state.item.heading || 'Promotional item'}</div>
        </div>
        {
          this.state.collapsed && <div className='collapse-item'>
            <form onSubmit={this.handleSubmitForm}>
              <div className='background-image'>
                <label>Image</label>
                { this.state.item.image_url && <img src={this.state.item.image_url} alt='item-image'/>}
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
                <label>Text</label>
                <SimpleCkeditor 
                  name='text'
                  value={this.state.item.text || ''}
                  id={this.state.item.id}
                  handleOnChange={this.handleOnChange}
                />
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
                <label>Link</label>
                <input name='link' value={this.state.item.link || ''} type='text' onChange={this.handleOnChange}/>
              </div>
              <div className='form-control'>
                <label>Button text</label>
                <input name='button_text' value={this.state.item.button_text || ''} type='text' onChange={this.handleOnChange}/>
              </div>
              <div className='form-control'>
                <label>Button style</label>
                <select name='button_style' defaultValue={this.state.item.button_style} onChange={this.handleOnChange}>
                  <option value='primary'>Primary</option>
                </select>
              </div>
              <div className='form-control'>
                <label>Width</label>
                <select name='width' defaultValue={this.state.item.width}>
                  { 
                    Object.entries(widths).map(i => {
                      return <option key={i[0]} value={i[0]}>{i[1]}</option>
                    })
                  }
                </select>
              </div>
              <div className='row'>
                <div className='col-8'>
                  <button className='p-2 btn' type='button' onClick={() => this.props.handleRemoveItem(this.state.item)}>{ this.props.removing ? 'Removing...' : 'Remove content'}</button>
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

export default StoreGridItem