import React, { Component } from  'react'
import axios from 'axios'
import MultiSelect from "react-multi-select-component";
import countryList from 'react-select-country-list'
import currency_iso from '../../../assets/json/currency_iso.json'
import SimpleCkeditor from '../../elements/SimpleCkeditor'

const renameKeys = (arr) => {
  const newArray = arr.map(elm => {
    return {value: elm.abbr, label: elm.name}
  })

  return newArray
}

const currencyOptions = () => {
  const values = Object.keys(currency_iso)
  let options = []
  values.map(v => {
    options.push({value: v, label: `${currency_iso[v].name}(${v.toUpperCase()})`})
  })
  return options
}

class StoreFooterItem extends Component {
  
  constructor(props) {
    super(props)
    this.handleToggleItem = this.handleToggleItem.bind(this)
    this.handleOnChange = this.handleOnChange.bind(this)
    this.handleSubmitForm = this.handleSubmitForm.bind(this)
    this.setLanguageSelected = this.setLanguageSelected.bind(this)
    this.setCurencySelected = this.setCurencySelected.bind(this)

    this.languageOptions = countryList().getData()
    this.currencyOptions = currencyOptions()

    this.state = {
      saving: false,
      removing: false,
      collapsed: false,
      isLanguage: false,
      isCurrency: false,
      languageOptions: this.languageOptions,
      currencyOptions: this.currencyOptions,
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

  setLanguageSelected(items) {
    this.setState({
      item: {
        ...this.state.item,
        languages: items
      }
    })
  }

  setCurencySelected(items) {
    this.setState({
      item: {
        ...this.state.item,
        currency: items
      }
    })
  }

  isNormal() {
    return this.state.item.content_type === 'normal'
  }

  isLanguage() {
    return this.state.item.content_type === 'language'
  }

  isCurrency() {
    return this.state.item.content_type === 'currency'
  }

  renderContent() {
    const { item } = this.state
    const languages = item.languages || []
    const currencies = item.currency || []
    if (this.isLanguage()) {
      return (
        <div>
          <MultiSelect
            options={this.state.languageOptions}
            value={item.languages}
            className='featured-list'
            onChange={this.setLanguageSelected}
            labelledBy={"Select languages"}
          />
          <ul>
            {  
              languages.map(l => {
                return <li key={l.value}>
                  <i className="icon-check"></i>
                  {l.label}
                </li>
              })
            }
          </ul>
        </div>
      )
    } else if (this.isCurrency()) {
      return (
        <div>
          <MultiSelect
            options={this.state.currencyOptions}
            value={item.currency}
            className='featured-list'
            onChange={this.setCurencySelected}
            labelledBy={"Select currency"}
          />
          <ul>
            {  
              currencies.map(l => {
                return <li key={l.value}>
                  <i className="icon-check"></i>
                  {l.label}
                </li>
              })
            }
          </ul>
        </div>
      )
    } else {
      return <div>
        <div className='form-control'>
          <label>Sub Heading</label>
          <input name='sub_heading' value={item.sub_heading} type='text' onChange={this.handleOnChange}/>
        </div>
        <div className='form-control'>
          <label>Text</label>
          <SimpleCkeditor 
            name='text'
            value={item.text || ''}
            id={item.id}
            handleOnChange={this.handleOnChange}
          />
        </div>
        <div className='form-control'>
          <label>Link</label>
          <input name='link' value={item.link} type='text' onChange={this.handleOnChange}/>
        </div>
      </div>
    }
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
                <input 
                  name='heading' 
                  value={item.heading} 
                  type='text' 
                  onChange={this.handleOnChange}
                />
              </div>
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
                  <label className='checkbox-label' htmlFor='normal-type'>None</label>
                </div>
                <div className='checkbox-control'>
                  <input type='radio'
                    name='content_type'
                    value='language'
                    className='checkbox-input'
                    id='language-type'
                    checked={this.isLanguage()}
                    onChange={this.handleOnChange}
                  />
                  <label className='checkbox-label' htmlFor='language-type'>Is Language</label>
                </div>
                <div className='checkbox-control'>
                  <input type='radio'
                    name='content_type'
                    value='currency'
                    className='checkbox-input'
                    id='currency-type'
                    checked={this.isCurrency()}
                    onChange={this.handleOnChange}
                  />
                  <label className='checkbox-label' htmlFor='currency-type'>Is Currency</label>
                </div>
              </div>
              {
                this.renderContent()
              }
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