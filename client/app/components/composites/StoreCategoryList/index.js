import React, { Component } from 'react'
import StoreCategoryItem from '../StoreCategoryItem'
import axios from 'axios'
import { randomString } from '../../../utils/common'

class StoreCategoryList extends Component {
  constructor(props) {
    super(props)
    this.state = {
      saving: false,
      removing: false,
      object: props.object
    }

    this.handleOnChange = this.handleOnChange.bind(this)
    this.handleOnSubmit = this.handleOnSubmit.bind(this)
    this.handleAddItem = this.handleAddItem.bind(this)
    this.handleRemoveItem = this.handleRemoveItem.bind(this)
    this.handleUpdateNewItem = this.handleUpdateNewItem.bind(this)

    this.axiosDefaultParams = {
      authenticity_token: $('input[name ="authenticity_token"]').val()
    }
  }

  handleOnChange(e) {
    this.setState({
      object: {...this.state.object,
      [e.target.name]: e.target.value}
    })
  }

  handleOnSubmit(e) {
    e.preventDefault()
    
    const { object } = this.state

    let data = {
      ...this.axiosDefaultParams,
      store_category: {heading: object.heading}

    }

    let axiosOptions = {
      url: object.id ? `/admin/store_categories/${object.id}` : `/admin/store_categories`,
      method: object.id ? 'put' : 'post',
      data: data
    }

    this.setState({ saving: true })

    axios(axiosOptions).then(res => {
      if (res.status == 200 && res.data.success) {
        this.setState({
          object: res.data.store_category
        })
      }
      this.setState({
        saving: false,
      })
      $("#homepage-preview-iframe").attr("src", function(index, attr){ 
        return attr;
      });
    })
  }

  handleAddItem() {
    const newItem = {
      store_category_id: this.state.object.id
    }
    this.setState({
      object: {
        ...this.state.object,
        items: [...this.state.object.items, newItem]
      }
    })
  }

  handleUpdateNewItem(oldId, item){
    let items = this.state.object.items
  
    let oldItemIndex = items.findIndex(it => it.id === oldId)
    oldItemIndex > -1 ? items.splice(oldItemIndex, 1, item) : items.push(item)
    this.setState({
      object: {
        ...this.state.object,
        items: items
      }
    })
  }

  handleRemoveItem(item) {
    // TODO
    this.setState({ removing: true })
  
    axios.delete(`/admin/store_categories/${item.store_category_id}/store_category_items/${item.id}`, {data: this.axiosDefaultParams}).then(res => {
      this.setState({removing: false})
      let items = this.state.object.items.filter(it => it.id != item.id)
      this.setState({
        object: {
          ...this.state.object,
          items: items
        }
      })

      this.setState({ removing: false })

      $("#homepage-preview-iframe").attr("src", function(index, attr){ 
        return attr;
      });
    })
  }

  render() {
    return( 
      <div className='store-header store-slideshow'>
        <div className='breabcrum' onClick={() => this.props.callback(undefined)}>
          <i className="icon-chevron-left"></i>
          <span>{this.state.object.heading || 'Category List'}</span>
        </div>
        <h1 className=''>Settings</h1>
        <div className='main-form-content'>
          <form onSubmit={this.handleOnSubmit}>
            <div className='form-control'>
              <label>Heading</label>
              <input name='heading' value={this.state.object.heading || ''} type='text' onChange={this.handleOnChange}/>
            </div>
            <button className='btn' type='submit'>{ this.state.saving ? 'Saving...' : 'Save'} </button> 
          </form>
        </div>
        <h1>Contents</h1>
        <ul className='slide-list'>
          { 
            this.state.object.items.map(item => {
              return <li key={item.id || randomString()}>
                <StoreCategoryItem 
                  key={item.id || randomString()} 
                  item={item}
                  removing={this.state.removing}
                  handleUpdateNewItem={this.handleUpdateNewItem}
                  handleRemoveItem={this.handleRemoveItem}
                />
              </li>
            })
          }
        </ul>
        <div className='add-more-slide'>
          <button className='btn' type='button' onClick={this.handleAddItem}>Add category</button>
        </div>
      </div>
    )
  }
}

StoreCategoryList.defaultProps = {
  object: {
    heading: 'Category List',
    items: []
  }
}

export default StoreCategoryList