import React, { Component } from 'react'
import SimpleCkeditor from '../../elements/SimpleCkeditor'

class SignUp extends Component {
  constructor(props) {
    super(props)
    this.state = {
      ready: false,
      item: props.item,
    }
  }

  render() {
    const { item } = this.props
    return(
      <div>
        <div className='form-control'>
          <label>Heading</label>
          <input name='heading' value={item.heading} type='text' onChange={this.props.handleOnChange}/>
        </div>
        <div className='form-control'>
          <label>Subheading</label>
          <SimpleCkeditor 
            name='text'
            value={item.text || ''}
            id={item.id}
            handleOnChange={this.props.handleOnChange}
          />
        </div>
      </div>
    )
  }
}

SignUp.defaultProps = {
  item: {}
}

export default SignUp