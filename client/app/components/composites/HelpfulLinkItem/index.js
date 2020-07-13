import React, { Component } from 'react'
import ContactInformation from './ContactInformation.jsx'
import CustomerService from './CustomerService.jsx'
import SocialAccount from './SocialAccount.jsx'
import { SketchPicker } from 'react-color'
import { PickColorstyles } from '../../../utils/common'
import axios from 'axios'

class HelpfulLinkItem extends Component {

  constructor(props) {
    super(props)
    this.handleToggleItem = this.handleToggleItem.bind(this)
    this.handleOnChange = this.handleOnChange.bind(this)
    this.handleSubmitForm = this.handleSubmitForm.bind(this)
    this.handleColorClose = this.handleColorClose.bind(this)
    this.handleColorToggle = this.handleColorToggle.bind(this)
    this.handleColorChangeComplete = this.handleColorChangeComplete.bind(this)
    // this.handleRemoveItem = this.handleRemoveItem.bind(this)

    this.state = {
      saving: false,
      removing: false,
      collapsed: false,
      headingColorEnabled: false,
      textColorEnabled: false,
      item: props.item
    }
  }

  handleToggleItem() {
    this.setState({ collapsed: !this.state.collapsed })
  }

  handleOnChange(e) {
    let { value } = e.target
    if (e.target.type === 'checkbox') {
      value = e.target.checked
    }
    const item = {
      ...this.state.item,
      [e.target.name]: value
    }

    this.setState({
      item: item
    })
  }

  handleSubmitForm(e) {
    e.preventDefault()
    const { item } = this.state
    let itemParams = item
    let subItems = itemParams.sub_items
    subItems.forEach(element => {
      if (!element.created_at) {
        delete element.id
      }
    })
    if (this.isFooterLink()) {
      itemParams['footer_links_attributes'] = subItems
    }
    if (this.isSocialAccount()) {
      itemParams['footer_social_accounts_attributes'] = subItems
    }

    let dataParams = {
      authenticity_token: $('input[name ="authenticity_token"]').val(),
      helpful_link_item: itemParams
    }
    let formData = new FormData()

    if (this.isSocialAccount()) {
      formData.append('authenticity_token', $('input[name ="authenticity_token"]').val())
      for (let key in itemParams) {
        if (key === 'footer_social_accounts_attributes') {
          itemParams['footer_social_accounts_attributes'].map((attr, index) => {
            for (let k in attr) {
              let value = null
              if (k === 'image') {
                value = attr[k][0]
              } else {
                value = attr[k]
              }
              formData.append(`helpful_link_item[footer_social_accounts_attributes][][${k}]`, value)
            }
          })
        } else {
          formData.append(`helpful_link_item[${key}]`, itemParams[key])
        }
      }
    }

    const axiosOptions = {
      url: item.id ? `/admin/helpful_links/${item.helpful_link_id}/helpful_link_items/${item.id}` :  `/admin/helpful_links/${item.helpful_link_id}/helpful_link_items`,
      method: item.id ? 'put' : 'post',
      data: this.isSocialAccount() ? formData : dataParams
    }
    this.setState({saving: true})
    axios(axiosOptions).then(res => {
      this.setState({
        saving: false,
        collapsed: false,
        item: res.data.item
      })
      this.props.handleUpdateNewItem(item.id, res.data.item)
      $("#homepage-preview-iframe").attr("src", function(index, attr){ 
        return attr;
      });
    })
  }

  isNormal() {
    return this.state.item.content_type === 'normal'
  }

  isFooterLink() {
    return this.state.item.content_type === 'footer_link'
  }

  isSocialAccount() {
    return this.state.item.content_type === 'social_account'
  }

  handleColorClose(target) {
    this.setState({
      [target]: false
    })
  }

  handleColorToggle(target) {
    this.setState({
      [target]: !this.state[target]
    })
  }

  handleColorChangeComplete(target, color) {
    this.setState({
      item: {
        ...this.state.item,
        [target]: color.hex
      }
    })
  }

  renderContent() {
    let { item } = this.state
    console.log(item)
    if (this.isFooterLink()) {
      return <CustomerService 
        item={item}
        handleOnChange={this.handleOnChange}
      />
    } else if (this.isSocialAccount()) {
      return <SocialAccount 
        item={item}
        handleOnChange={this.handleOnChange}
      />
    } else {
      return <ContactInformation
        item={item}
        handleOnChange={this.handleOnChange}
      />
    }
  }

  render() {
    const { item } = this.state
    return(
      <div className='collapsible store-category-item slideshow-item'>
        <div className='row section-column-header-toggle' onClick={this.handleToggleItem}>
          <i className={`icon-caret-right ${this.state.collapsed ? 'down' : ''}`}></i>
          <div className='heading-title'>{this.state.item.heading || 'Content'}</div>
        </div>
        {
          this.state.collapsed && <div className='collapse-item'>
            <form onSubmit={this.handleSubmitForm}>
              <div className='content-type-control'>
                <div className='form-control'>
                  <div className='checkbox-control'>
                    <input type='radio' 
                      name='content_type'
                      value={'normal'}
                      className='checkbox-input'
                      id='normal-type'
                      checked={this.isNormal()}
                      onChange={this.handleOnChange}
                    />
                    <label className='checkbox-label' htmlFor='normal-type'>None (Contact Information)</label>
                  </div>
                  <div className='checkbox-control'>
                    <input type='radio'
                      name='content_type'
                      value='footer_link'
                      className='checkbox-input'
                      id='footer-link'
                      checked={this.isFooterLink()}
                      onChange={this.handleOnChange}
                    />
                    <label className='checkbox-label' htmlFor='footer-link'>Footer Link (Information/ Customer service)</label>
                  </div>
                  <div className='checkbox-control'>
                    <input type='radio'
                      name='content_type'
                      value='social_account'
                      className='checkbox-input'
                      id='social-account'
                      checked={this.isSocialAccount()}
                      onChange={this.handleOnChange}
                    />
                    <label className='checkbox-label' htmlFor='social-account'>Social Account(Follow us)</label>
                  </div>
                </div>
              </div>
              <hr></hr>
              { this.renderContent() }
              <div className='form-control'>
                <button
                    type='button'
                    className='color-box' 
                    style={{backgroundColor: item.heading_color}} 
                    onClick={() => this.handleColorToggle('headingColorEnabled')}>
                </button>
                <label>Heading color</label>
                {this.state.headingColorEnabled && 
                  <div>
                    <div style={ PickColorstyles.cover } onClick={() => this.handleColorClose('headingColorEnabled')}/>
                    <SketchPicker
                      color={ item.heading_color }
                      onChangeComplete={(e) => this.handleColorChangeComplete('heading_color', e) }
                    />
                  </div>
                }
              </div>
              <div className='form-control'>
                <button
                    type='button'
                    className='color-box' 
                    style={{backgroundColor: item.text_color}} 
                    onClick={() => this.handleColorToggle('textColorEnabled')}>
                </button>
                <label>Text/Subheading color</label>
                {this.state.textColorEnabled && 
                  <div>
                    <div style={ PickColorstyles.cover } onClick={() => this.handleColorClose('textColorEnabled')}/>
                    <SketchPicker
                      color={ item.text_color }
                      onChangeComplete={(e) => this.handleColorChangeComplete('text_color', e) }
                    />
                  </div>
                }
              </div>
              <div className='checkbox-control'>
                <input 
                  className='checkbox-input' 
                  name='enabled' 
                  type='checkbox'
                  checked={item.enabled || false}
                  onChange={this.handleOnChange}
                  id='item-enabled' />
                <label htmlFor='item-enabled' className='checkbox-label'>Enable</label>
              </div>
              <div className='row'>
                <div className='col-8'>
                  <button className='p-2 btn' type='button' onClick={() => this.props.handleRemoveItem(item)}>{ this.props.removing ? 'Removing...' : 'Remove content'}</button>
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

export default HelpfulLinkItem