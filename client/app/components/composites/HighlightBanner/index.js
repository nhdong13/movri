import React, { Component }  from 'react'
import { SketchPicker } from 'react-color'
import axios from 'axios'
import {  randomString } from '../../../utils/common'
import BannerItem from '../BannerItem'

class HighlightBanner extends Component {

  constructor(props) {
    super(props)

    this.state = {
      object: props.object,
      textColorEnabled: false,
      bgColorEnabled: false,
      saving: false,
      authenticity_token: $('input[name ="authenticity_token"]').val()
    }

    this.handleTextColorChangeComplete = this.handleTextColorChangeComplete.bind(this)
    this.handleBgColorChangeComplete = this.handleBgColorChangeComplete.bind(this)
    this.handleColorClose = this.handleColorClose.bind(this)
    this.handleBgColorClose = this.handleBgColorClose.bind(this)
    this.colorPickToggle = this.colorPickToggle.bind(this)
    this.bgPickToggle = this.bgPickToggle.bind(this)
    this.handleSubmitForm = this.handleSubmitForm.bind(this)
    this.handleAddItem = this.handleAddItem.bind(this)
    this.handleRemoveItem = this.handleRemoveItem.bind(this)
    this.handleUpdateNewItem = this.handleUpdateNewItem.bind(this)

    this.axiosDefaultParams = {
      authenticity_token: $('input[name ="authenticity_token"]').val()
    }

  }

  handleTextColorChangeComplete(color) {
    this.setState({
      object: {
        ...this.state.object,
        text_color: color.hex
      }
    })
  }

  handleBgColorChangeComplete(color) {
    this.setState({
      object: {
        ...this.state.object,
        background_color: color.hex
      }
    })
  }

  handleColorClose() {
    this.setState({textColorEnabled: false})
  }

  handleBgColorClose() {
    this.setState({bgColorEnabled: false})
  }

  colorPickToggle() {
    this.setState({
      textColorEnabled: !this.state.textColorEnabled
    })
  }

  bgPickToggle() {
    this.setState({
      bgColorEnabled: !this.state.bgColorEnabled
    })
  }

  handleOnChange(e) {
    let { value }  = e.target
    if (e.target.type === 'checkbox') {
      value = e.target.checked
    }

    this.setState({
      item: {
        ...this.state.object,
        [e.target.name]: value
      }
    })
  }

  handleSubmitForm(e) {
    e.preventDefault()
    const { object } = this.state
    const params = {
      ...this.axiosDefaultParams,
      highlight_banner: {
        enabled: object.enabled,
        text_color: object.text_color,
        background_color: object.background_color
      }
    }
    this.setState({saving: true})
    axios.put(`/admin/highlight_banners/${object.id}`, params).then(res => {
      this.setState({saving: false})
      $("#homepage-preview-iframe").attr("src", function(index, attr){ 
        return attr;
      });
    })
  }

  handleRemoveItem(item) {
    const params = {
      authenticity_token: this.state.authenticity_token
    }
    axios.delete(`/admin/highlight_banners/${item.highlight_banner_id}/banner_items/${item.id}`, {data: params}).then(res => {
      this.setState({removing: false})
      let bannerItems = this.state.object.banner_items.filter(it => it.id != item.id)
      this.setState({
        object: {
          ...this.state.object,
          banner_items: bannerItems
        }
      })
      $("#homepage-preview-iframe").attr("src", function(index, attr){ 
        return attr;
      });
    })
  }

  handleAddItem() {
    axios.get(`/admin/highlight_banners/${this.state.object.id}/banner_items/new`, this.axiosDefaultParams).then(res => {
      if (res.data.success) {
        const item = res.data.banner_item
        this.setState({
          object: {
            ...this.state.object,
            banner_items: [...this.state.object.banner_items, item]
          }
        })
      }
    })
  }

  handleUpdateNewItem(oldId, item){
    let bannerItems = this.state.object.banner_items
    let oldItemIndex = bannerItems.findIndex(it => it.id === oldId)
    oldItemIndex > 0 ? bannerItems.splice(oldItemIndex, 1, item) : bannerItems.push(item)
    this.setState({
      object: {
        ...this.state.object,
        banner_items: bannerItems
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

    let bannerItems = this.state.object.banner_items

    return (
      <div className='store-header store-slideshow'>
        <div className='breabcrum' onClick={() => this.props.toggleActiveSub('')}>
          <i className="icon-chevron-left"></i>
          <span>Highlights Banner</span>
        </div>
        <h1 className=''>Settings</h1>
        <div className='main-form-content'>
          <form onSubmit={this.handleSubmitForm}>
            <div className='checkbox-control'>
              <input 
                className='checkbox-input' 
                name='enabled' 
                type='checkbox'
                checked={this.state.object.enabled}
                onChange={this.handleOnChange}
                id='enabled' />
              <label htmlFor='enabled' className='checkbox-label'>Enable highlights banner</label>
            </div>
            <div className='form-control'>
              <button
                type='button'
                className='color-box' 
                style={{backgroundColor: this.state.object.text_color}} 
                onClick={this.colorPickToggle}>
              </button>
              <label>Text color</label>
              {this.state.textColorEnabled && 
                <div>
                  <div style={ styles.cover } onClick={ this.handleColorClose }/>
                  <SketchPicker
                    color={ this.state.object.text_color }
                    onChangeComplete={ this.handleTextColorChangeComplete }
                  />
                </div>
              }
            </div>
            <div className='form-control'>
              <button
                type='button'
                className='color-box' 
                style={{backgroundColor: this.state.object.background_color}} 
                onClick={this.bgPickToggle}>
              </button>
              <label>Background color</label>
              {this.state.bgColorEnabled && 
                <div>
                  <div style={ styles.cover } onClick={ this.handleBgColorClose }/>
                  <SketchPicker
                    color={ this.state.object.backgroud_color }
                    onChangeComplete={ this.handleBgColorChangeComplete }
                  />
                </div>
              }
            </div>
            <button className='btn' type='submit'>{this.state.saving ? 'Saving...' : 'Save'}</button>
          </form>
        </div>
        <h1>Contents</h1>
        <ul className='slide-list'>
          { 
            bannerItems.map(item => {
              return <li key={item.id || randomString()}>
                <BannerItem 
                  key={item.id || randomString()} 
                  item={item}
                  handleUpdateNewItem={this.handleUpdateNewItem}
                  handleRemoveItem={this.handleRemoveItem}
                />
              </li>
            })
          }
        </ul>
        <div className='add-more-slide'>
          <button className='btn' type='button' onClick={this.handleAddItem}>Add block</button>
        </div>
      </div>
    )
  }
}

HighlightBanner.defaultProps = {
  object: {
    banner_items: []
  }
}

export default HighlightBanner