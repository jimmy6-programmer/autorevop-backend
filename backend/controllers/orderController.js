const Order = require('../models/Order');
const SparePart = require('../models/SparePart');
const Notification = require('../models/Notification');

// Get all orders
exports.getOrders = async (req, res) => {
  try {
    const orders = await Order.find().sort({ createdAt: -1 });
    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching orders' });
  }
};

// Get order by ID
exports.getOrderById = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }
    res.json(order);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching order' });
  }
};

// Create new order
exports.createOrder = async (req, res) => {
  try {
    const order = new Order(req.body);
    await order.save();

    // Update inventory quantities
    for (const item of order.items) {
      await SparePart.findOneAndUpdate({ id: item.productId }, {
        $inc: { quantity: -item.quantity }
      });
    }

    // Create notification for new order
    const notification = new Notification({
      type: 'info',
      title: 'New Order Received',
      message: `Order ${order._id} has been placed by ${order.customerName}`,
      relatedId: order._id,
      relatedType: 'order',
    });
    await notification.save();

    // Check for low stock items
    for (const item of order.items) {
      const sparePart = await SparePart.findOne({ id: item.productId });
      if (sparePart && sparePart.quantity <= 5) {
        const lowStockNotification = new Notification({
          type: 'warning',
          title: 'Low Stock Alert',
          message: `${sparePart.name} inventory is running low (${sparePart.quantity} units remaining)`,
          relatedId: sparePart.id,
          relatedType: 'inventory',
        });
        await lowStockNotification.save();
      }
    }

    res.status(201).json(order);
  } catch (error) {
    res.status(500).json({ message: 'Error creating order' });
  }
};

// Update order
exports.updateOrder = async (req, res) => {
  try {
    const order = await Order.findByIdAndUpdate(req.params.id, req.body, { new: true, runValidators: true });
    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }

    // Create notification for order status update
    if (req.body.status && req.body.status !== order.status) {
      const notification = new Notification({
        type: 'success',
        title: 'Order Status Updated',
        message: `Order ${order._id} status changed to ${req.body.status}`,
        relatedId: order._id,
        relatedType: 'order',
      });
      await notification.save();
    }

    res.json(order);
  } catch (error) {
    res.status(500).json({ message: 'Error updating order' });
  }
};

// Delete order
exports.deleteOrder = async (req, res) => {
  try {
    const order = await Order.findByIdAndDelete(req.params.id);
    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }
    res.json({ message: 'Order deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting order' });
  }
};