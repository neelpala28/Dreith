# Dreith

A Flutter-based social networking application designed to foster meaningful professional connections within specialized communities. Dreith helps professionals connect with others in their field, creating a space where they can seek guidance, share knowledge, and build valuable relationships.

## 🌟 Features

- **Professional Networking**: Connect with professionals who share your field of expertise
- **Social Feed**: Browse and interact with posts from your community
- **Engagement Tools**: 
  - Create and share posts
  - Like and comment on content
  - Share posts with your network
  - Follow professionals in your field
- **Profile Management**: 
  - Customizable user profiles
  - Profile views tracking
  - Edit profile information
  - View followers and following lists
- **Discovery**: Browse and discover professionals in your community

### 🚀 Upcoming Features

- Direct messaging system
- Advanced user search by username
- Enhanced content filtering
- Notification system

## 💡 The Problem It Solves

Dreith addresses the challenge of finding and connecting with professionals in your specific field. Whether you're seeking mentorship, collaboration opportunities, or expert advice, Dreith makes it easy to reach out to people who understand your industry and can provide meaningful support.

## 🛠️ Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase
  - Firebase Authentication
  - Cloud Firestore
  - Firebase Storage
- **Media Management**: Cloudinary for optimized image storage and delivery
- **State Management**: Provider

## 📱 Screenshots

*Screenshots will be added soon*

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase account
- Cloudinary account

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/neelpala28/Dreith.git
   cd Dreith
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Firebase Authentication (Email/Password)
   - Create a Cloud Firestore database
   - Enable Firebase Storage
   - The Firebase configuration files are already included in the project

4. **Cloudinary Setup**
   - Create an account at [Cloudinary](https://cloudinary.com/)
   - Update your Cloudinary credentials in the project configuration

5. **Run the app**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── core/
│   └── theme_data.dart          # App theme configuration
├── models/
│   ├── post_model.dart          # Post data model
│   └── user_model.dart          # User data model
├── providers/
│   └── user_provider.dart       # User state management
├── screens/
│   ├── auth/
│   │   ├── login.dart           # Login screen
│   │   ├── sign_up.dart         # Sign up screen
│   │   └── forgot_password.dart # Password recovery
│   ├── home/
│   │   ├── home_screen.dart     # Main home screen
│   │   ├── home_feed_page.dart  # Feed display
│   │   └── create_post_screen.dart
│   ├── profile/
│   │   ├── profile_page.dart
│   │   ├── edit_profile.dart
│   │   ├── followers_list.dart
│   │   └── following_list.dart
│   ├── post/
│   │   └── post_details.dart
│   └── search/
│       └── search_page.dart
├── services/
│   ├── auth_service.dart        # Authentication logic
│   └── user_service.dart        # User data operations
├── widgets/
│   ├── bottom_nav.dart          # Bottom navigation bar
│   └── profile_picture_view.dart
└── main.dart                    # App entry point
```

## 🔧 Configuration

### Firebase Configuration

The Firebase configuration is managed through:
- `firebase.json` - Firebase project configuration
- `lib/firebase_options.dart` - Platform-specific Firebase options
- `android/app/google-services.json` - Android configuration
- `ios/Runner/GoogleService-Info.plist` - iOS configuration

## 🤝 Contributing

Contributions are welcome! If you'd like to contribute:

1. Fork the repository
2. Create a new branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

## 👤 Author

**Neel Pala**

- GitHub: [@neelpala28](https://github.com/neelpala28)
- Project Link: [https://github.com/neelpala28/Dreith](https://github.com/neelpala28/Dreith)
- LinkedIn: (https://www.linkedin.com/in/neelpala28)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend infrastructure
- Cloudinary for media management
- All contributors and supporters of this project

## 📧 Contact

For any queries or suggestions, feel free to reach out or open an issue on GitHub.

---

**Made with ❤️ using Flutter**
