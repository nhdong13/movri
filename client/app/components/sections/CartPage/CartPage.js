import React from 'react';
import { connect } from 'react-redux';
import { changeQuantityCartItem } from "../../../actions/CartActions"

class CartPage extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      cart: {
        item: {
          quantity: 1,
          price: 1000,
          coverage: 200,
          promo_code: 200
        }
      }
    }
  }

  handleChange(e) {
    let {cart} = {...this.state}
    cart.item[e.target.name] = e.target.value
    this.setState({cart: cart})
    this.props.changeQuantityCartItem(e.target.value, cart)
  }

  render() {
    debugger
    const item = this.state.cart.item
    return (
      <div>
        <div className="cart-header">
          <div className="row">
            <div className="col-3">
              <span>My Cart</span>
            </div>
            <div className="col-7">
              <span>Subtotal</span>
              <div className="price">
                <span>$129.00</span>
                <span>/4 days rental</span>
              </div>
            </div>
            <div className="col-2">
              <button className="common-btn btn-checkout">
                <i>
                  <div className="icon-lock fa-fw"></div>
                </i>
                <span className="uppercase"> Checkout </span>
              </button>
            </div>
          </div>
        </div>
        <div className="col-8">
          <div className="listing-info">
            <div className="content">
              <div className="row">
                <div className="col-2">
                </div>
                <div className="col-4">
                  <img src="mf_icons/icon-movri-mobile-cart.svg" className="img-responsive-cart"/>
                  <span> {item.title} </span>
                </div>
                <div className="col-3">
                  <div className="quantity-box">
                    <span> Quantity </span>
                    <input
                      id="quantity"
                      name="quantity"
                      type='text'
                      value={this.state.cart.item.quantity}
                      onChange={this.handleChange.bind(this)}
                    />
                  </div>
                </div>
                <div className="col-3">
                  <div className="cart-item">
                    <span> Price: </span>
                    <span id="price-item"> {this.state.cart.item.price} </span>
                  </div>
                  <div className="cart-item" id="coverage">
                    <span> Coverage: </span>
                    <span> {this.state.cart.item.coverage} </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}

const mapStateToProps = function mapStateToProps(state) {
  debugger
  return {
    listing: state.listingcart,
  };
};

const mapDispatchToProps = {
  changeQuantityCartItem: changeQuantityCartItem
}

export default connect(mapStateToProps, mapDispatchToProps)(CartPage);