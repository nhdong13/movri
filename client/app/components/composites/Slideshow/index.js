import React, { Component } from 'react'
import axios from 'axios'
import SlideItem from '../SlideItem'

const randomString = () => {
  return Math.random().toString(36).substring(7)
}

class Slideshow extends Component {
  constructor(props) {
    super(props)
    this.handleSubmitForm = this.handleSubmitForm.bind(this)
    this.handleFormOnChange = this.handleFormOnChange.bind(this)
    this.handleRemoveItem = this.handleRemoveItem.bind(this)
    this.handleAddItem = this.handleAddItem.bind(this)


    this.state = {
      loading: false,
      object: props.object,
      authenticity_token: $('input[name ="authenticity_token"]').val()
    }

    this.axiosDefaultParams = {
      authenticity_token: $('input[name ="authenticity_token"]').val()
    }
  }

  handleSubmitForm(e) {
    e.preventDefault()
    const { object } = this.state
    const params = {
      ...this.axiosDefaultParams,
      enabled: object.enabled,
      auto_play: object.auto_play,
      slide_duration: object.slide_duration
    }
    this.setState({loading: true})
    axios.put(`/admin/slideshows/${this.state.object.id}`, params).then(res => {
      this.setState({loading: false})
      $("#homepage-preview-iframe").attr("src", function(index, attr){ 
        return attr;
      });
    })
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

  handleRemoveItem(item) {
    const params = {
      authenticity_token: this.state.authenticity_token
    }
    axios.delete(`/admin/slideshows/${item.slideshow_id}/slide_items/${item.id}`, {data: params}).then(res => {
      this.setState({removing: false})
      let slide_items = this.state.object.slide_items.filter(it => it.id != item.id)
      this.setState({
        object: {
          ...this.state.object,
          slide_items: slide_items
        }
      })
      $("#homepage-preview-iframe").attr("src", function(index, attr){ 
        return attr;
      });
    })
  }

  handleAddItem() {
    axios.get(`/admin/slideshows/${this.state.object.id}/slide_items/new`, this.axiosDefaultParams).then(res => {
      if (res.data.success) {
        const item = res.data.slide_item
        this.setState({
          object: {
            ...this.state.object,
            slide_items: [...this.state.object.slide_items, item]
          }
        })
      }
    })
  }

  render() {
    let slideItems = this.state.object.slide_items
    return(
      <div className='store-header store-slideshow'>
        <div className='breabcrum' onClick={() => this.props.toggleActiveSub('')}>
          <i className="icon-chevron-left"></i>
          <span>Slideshow</span>
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
                onChange={this.handleFormOnChange}
                id='enabled' />
              <label htmlFor='enabled' className='checkbox-label'>Enable slideshow</label>
            </div>
            <div className='checkbox-control'>
              <input 
                className='checkbox-input' 
                name='auto_play' 
                type='checkbox'
                checked={this.state.object.auto_play}
                onChange={this.handleFormOnChange}
                id='auto_play' />
              <label htmlFor='auto_play' className='checkbox-label'>Autoplay slideshow</label>
            </div>
            <div className='row'>
              <label className='col-8'>Autoplay duration(sec)</label>
              <input className='col-4' type='number' name='slide_duration' value= {this.state.object.slide_duration}  onChange={this.handleFormOnChange}></input>
            </div>
            <button type='submit'>{this.state.loading ? 'Saving...' : 'Save'}</button>
          </form>
        </div>
        <hr/>
        <h1 className=''>Content</h1>
        <ul className='slide-list'>
          { 
            slideItems.map(item => {
              return <li key={item.id || randomString()}>
                <SlideItem 
                  key={item.id || randomString()} 
                  item={item}
                  handleRemoveItem={this.handleRemoveItem}
                />
              </li>
            })
          }
        </ul>
        <div className='add-more-slide'>
          <button type='button' onClick={this.handleAddItem}>Add slide</button>
        </div>
      </div>
    )
  }
}

Slideshow.defaultProps = {
  object: {
    slide_items: []
  }
}
export default Slideshow