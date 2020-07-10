import React, { Component } from 'react'
import { randomString, PickColorstyles } from '../../../utils/common'

class CustomerService extends Component {
  constructor(props) {
    super(props)
    this.state = {
      item: props.item,
      sub_items: props.item.sub_items
    }

    this.handleAddNewSubItem = this.handleAddNewSubItem.bind(this)
    this.handleItemOnChange = this.handleItemOnChange.bind(this)
  }

  handleAddNewSubItem() {
    const subItem = {
      sub_heading: '',
      link: '',
      id: randomString()
    }

    const subItems =  [...this.props.item.sub_items, subItem]

    this.props.handleOnChange({target: {name: 'sub_items', value: subItems}})
  }

  handleItemOnChange(id, e) {
    let subItems = this.props.item.sub_items
    let subItem = subItems.find(i => i.id === id)
    let oldItemIndex = subItems.findIndex(it => it.id === id)
    subItem = {
      ...subItem,
      [e.target.name]: e.target.value
    }

    oldItemIndex > -1 ? subItems.splice(oldItemIndex, 1 , subItem) : subItems.push(subItem)

    this.props.handleOnChange({target: {name: 'sub_items', value: subItems}})
  }

  render() {
    const { item } = this.props
    return(
      <div>
        <div className='form-control'>
          <label>Heading</label>
          <input name='heading' value={item.heading} type='text' onChange={this.props.handleOnChange}/>
        </div>
        {
          item.sub_items.map(sub => {
            return(
              <div key={sub.id || randomString()}>
                <div className='form-control'>
                  <label>Sub Heading</label>
                  <input name='sub_heading' value={sub.sub_heading} type='text' onChange={(e) => this.handleItemOnChange(sub.id, e)}/>
                </div>
                <div className='form-control'>
                  <label>Link</label>
                  <input name='link' value={sub.link} type='text' onChange={(e) => this.handleItemOnChange(sub.id, e)}/>
                </div>
              </div>
            )
          })
        }
        <button className='p-2 btn' type='button' onClick={this.handleAddNewSubItem}>Add Sub heading</button>
      </div>
    )
  }
}

CustomerService.defaultProps = {
  item: {
    sub_items: []
  }
}
export default CustomerService