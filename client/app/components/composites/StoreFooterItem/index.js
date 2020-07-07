import React, { Component } from  'react'
import axios from 'axios'

class StoreFooterItem extends Component {
  
  constructor(props) {
    super(props)
    this.handleToggleItem = this.handleToggleItem.bind(this)
    this.handleOnChange = this.handleOnChange.bind(this)
    this.handleSubmitForm = this.handleSubmitForm.bind(this)

    this.state = {
      saving: false,
      removing: false,
      collapsed: false,
      item: props.item
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
    const dataParams = {
      authenticity_token: $('input[name ="authenticity_token"]').val(),
      store_footer_item: item
    }
    const axiosOptions = {
      url: item.id ? `/admin/store_footers/${item.store_footer_id}/store_footer_items/${item.id}` :  `/admin/store_footers/${item.store_footer_id}/store_footer_items`,
      method: item.id ? 'put' : 'post',
      data: dataParams
    }
    this.setState({saving: true})
    axios(axiosOptions).then(res => {
      this.setState({
        saving: false,
        collapsed: false,
      })
      this.props.handleUpdateNewItem(item.id, res.data.store_footer_item)
      $("#homepage-preview-iframe").attr("src", function(index, attr){ 
        return attr;
      });
    })
  }

  render() {
    let { item } = this.state
    return(
      <div className='collapsible store-category-item slideshow-item'>
        <div className='row section-column-header-toggle' onClick={this.handleToggleItem}>
          <i className={`icon-caret-right ${this.state.collapsed ? 'down' : ''}`}></i>
          <div className='heading-title'>{this.state.item.heading || 'Content'}</div>
        </div>
        {
          this.state.collapsed && <div className='collapse-item'>
            <form onSubmit={this.handleSubmitForm}>
              <div className='form-control'>
                <label>Heading</label>
                <input name='heading' value={item.heading} type='text' onChange={this.handleOnChange}/>
              </div>
              <div className='form-control'>
                <label>Sub Heading</label>
                <input name='sub_heading' value={item.sub_heading} type='text' onChange={this.handleOnChange}/>
              </div>
              <div className='form-control'>
                <label>Text</label>
                <textarea name='text' value={item.text} type='text' onChange={this.handleOnChange}/>
              </div>
              <div className='form-control'>
                <label>Link</label>
                <input name='link' value={item.link} type='text' onChange={this.handleOnChange}/>
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

export default StoreFooterItem