import React, { Component } from 'react'
import axios from 'axios'
import SlideItem from '../SlideItem'
import {
  sortableContainer,
  sortableElement,
} from 'react-sortable-hoc';
import arrayMove from 'array-move';
import _ from 'lodash';

const randomString = () => {
  return Math.random().toString(36).substring(7)
}

const SortableItem = sortableElement(({item, content}) => {
  return (
    <li key={item.id || randomString()}>
      {content}
    </li>
  )
});

const SortableContainer = sortableContainer(({children}) => {
  return <ul className='p-0'>{children}</ul>;
});

const sortByOrderNumber = (array) => {
  return array.sort((a,b) => (a.order_number > b.order_number) ? 1 : ((b.order_number > a.order_number) ? -1 : 0));
}
class Slideshow extends Component {
  constructor(props) {
    super(props)
    this.handleSubmitForm = this.handleSubmitForm.bind(this)
    this.handleFormOnChange = this.handleFormOnChange.bind(this)
    this.handleRemoveItem = this.handleRemoveItem.bind(this)
    this.handleAddItem = this.handleAddItem.bind(this)
    this.onSortEnd = this.onSortEnd.bind(this)
    this.handleUpdateItems = this.handleUpdateItems.bind(this)

    this.state = {
      loading: false,
      object: props.object,
      authenticity_token: $('input[name ="authenticity_token"]').val(),
      disabledDragable: false
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
      this.setState({})
      this.setState({
        removing: false,
        object: res.data.object
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
          },
          disabledDragable: true
        })
      }
    })
  }

  onSortEnd({oldIndex, newIndex}) {
    let slideItems = sortByOrderNumber(this.state.object.slide_items)
    let newSlideItems = arrayMove(slideItems, oldIndex, newIndex).map((item, index) => {
      return {...item, order_number: index + 1 }
    })

    this.setState({
      object: {...this.state.object, list_items: newSlideItems}
    })

    let dataParams = {
      authenticity_token: $('input[name ="authenticity_token"]').val(),
      slide_items: newSlideItems.map((item) => {return {id: item.id, order_number: item.order_number}})
    }
    const axiosOptions = {
      url: `/admin/slideshows/${this.state.object.id}/sort_items`,
      method: 'put',
      data: dataParams 
    }

    axios(axiosOptions).then(res => {
      this.setState({
        object: res.data.object
      })
      $("#homepage-preview-iframe").attr("src", function(index, attr){ 
        return attr;
      });
    })
  }

  handleUpdateItems(item) {
    let slideItems = this.state.object.slide_items.filter(it => !!it.id ) || []
    let idx = _.findIndex(slideItems, slide_item => slide_item.id === item.id )
    if(idx !== -1) {
      slideItems[idx] = item
    } else {
      slideItems = _.concat(slideItems, [item])
    }
    this.setState({
      object: { ...this.state.object, slide_items: sortByOrderNumber(slideItems) },
      disabledDragable: false
    })
  }

  render() {
    let slideItems = sortByOrderNumber(this.state.object.slide_items)
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
            <button className='btn' type='submit'>{this.state.loading ? 'Saving...' : 'Save'}</button>
          </form>
        </div>
        <hr/>
        <h1 className=''>Content</h1>
        <ul className='slide-list'>
          <SortableContainer onSortEnd={this.onSortEnd} useDragHandle>
            {slideItems.map((item, index) => (
              <SortableItem
                key={`item-${item.id}` || randomString()}
                index={index}
                item={item}
                disabled={this.state.disabledDragable}
                content={
                  <SlideItem
                    item={item}
                    handleRemoveItem={this.handleRemoveItem}
                    handleUpdateItems={this.handleUpdateItems}
                  />
                }/>
            ))}
          </SortableContainer>
        </ul>
        <div className='add-more-slide'>
          <button className='btn' type='button' onClick={this.handleAddItem}>Add slide</button>
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