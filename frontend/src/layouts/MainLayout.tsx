import React, { useState } from 'react';
import { Outlet, useNavigate, Link as RouterLink } from 'react-router-dom';
import {
  AppBar,
  Box,
  CssBaseline,
  Divider,
  Drawer,
  IconButton,
  List,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Toolbar,
  Typography,
  Button,
  Avatar,
  Menu,
  MenuItem,
  Tooltip,
  useMediaQuery,
  useTheme,
} from '@mui/material';
import {
  Menu as MenuIcon,
  Dashboard as DashboardIcon,
  Group as GroupIcon,
  Event as EventIcon,
  Person as PersonIcon,
  ExitToApp as LogoutIcon,
  Settings as SettingsIcon,
  AdminPanelSettings as AdminIcon,
} from '@mui/icons-material';
import { useAuth } from '../contexts/AuthContext';
import { isAdmin } from '../utils/auth.utils';

// Çekmece genişliği
const drawerWidth = 240;

/**
 * Ana Sayfa Düzeni
 * 
 * Uygulama içindeki tüm sayfalar için ortak düzeni sağlar
 */
const MainLayout: React.FC = () => {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('md'));
  
  // Çekmece durumu
  const [mobileOpen, setMobileOpen] = useState(false);
  
  // Profil menüsü durumu
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
  const open = Boolean(anchorEl);
  
  // Çekmece aç/kapa
  const handleDrawerToggle = () => {
    setMobileOpen(!mobileOpen);
  };
  
  // Profil menüsünü aç
  const handleProfileMenuOpen = (event: React.MouseEvent<HTMLElement>) => {
    setAnchorEl(event.currentTarget);
  };
  
  // Profil menüsünü kapat
  const handleProfileMenuClose = () => {
    setAnchorEl(null);
  };
  
  // Çıkış yap
  const handleLogout = async () => {
    handleProfileMenuClose();
    await logout();
    navigate('/login');
  };
  
  // Profil sayfasına git
  const handleProfileClick = () => {
    handleProfileMenuClose();
    navigate('/profile');
  };
  
  // Admin paneline git
  const handleAdminClick = () => {
    handleProfileMenuClose();
    navigate('/admin/dashboard');
  };
  
  // Çekmece içeriği
  const drawer = (
    <div>
      <Toolbar sx={{ justifyContent: 'center' }}>
        <Typography variant="h6" noWrap component="div">
          Sesli İletişim
        </Typography>
      </Toolbar>
      <Divider />
      <List>
        <ListItemButton component={RouterLink} to="/dashboard" onClick={() => isMobile && setMobileOpen(false)}>
          <ListItemIcon>
            <DashboardIcon />
          </ListItemIcon>
          <ListItemText primary="Dashboard" />
        </ListItemButton>
        
        <ListItemButton component={RouterLink} to="/groups" onClick={() => isMobile && setMobileOpen(false)}>
          <ListItemIcon>
            <GroupIcon />
          </ListItemIcon>
          <ListItemText primary="Gruplar" />
        </ListItemButton>
        
        <ListItemButton component={RouterLink} to="/sessions" onClick={() => isMobile && setMobileOpen(false)}>
          <ListItemIcon>
            <EventIcon />
          </ListItemIcon>
          <ListItemText primary="Oturumlar" />
        </ListItemButton>
      </List>
      
      <Divider />
      
      {isAdmin(user) && (
        <>
          <List>
            <ListItemButton component={RouterLink} to="/admin/dashboard" onClick={() => isMobile && setMobileOpen(false)}>
              <ListItemIcon>
                <AdminIcon />
              </ListItemIcon>
              <ListItemText primary="Admin Paneli" />
            </ListItemButton>
          </List>
          <Divider />
        </>
      )}
    </div>
  );
  
  return (
    <Box sx={{ display: 'flex' }}>
      <CssBaseline />
      
      {/* Üst Çubuk */}
      <AppBar
        position="fixed"
        sx={{
          width: { sm: `calc(100% - ${drawerWidth}px)` },
          ml: { sm: `${drawerWidth}px` },
        }}
      >
        <Toolbar>
          <IconButton
            color="inherit"
            aria-label="open drawer"
            edge="start"
            onClick={handleDrawerToggle}
            sx={{ mr: 2, display: { sm: 'none' } }}
          >
            <MenuIcon />
          </IconButton>
          
          <Typography variant="h6" noWrap component="div" sx={{ flexGrow: 1 }}>
            Sesli İletişim Platformu
          </Typography>
          
          {/* Profil Butonu */}
          <Tooltip title="Profil Ayarları">
            <IconButton
              onClick={handleProfileMenuOpen}
              size="small"
              sx={{ ml: 2 }}
              aria-controls={open ? 'account-menu' : undefined}
              aria-haspopup="true"
              aria-expanded={open ? 'true' : undefined}
            >
              <Avatar sx={{ width: 32, height: 32 }}>
                {user?.firstName?.charAt(0) || user?.email?.charAt(0) || 'U'}
              </Avatar>
            </IconButton>
          </Tooltip>
          
          {/* Profil Menüsü */}
          <Menu
            anchorEl={anchorEl}
            id="account-menu"
            open={open}
            onClose={handleProfileMenuClose}
            onClick={handleProfileMenuClose}
            PaperProps={{
              elevation: 0,
              sx: {
                overflow: 'visible',
                filter: 'drop-shadow(0px 2px 8px rgba(0,0,0,0.32))',
                mt: 1.5,
                '& .MuiAvatar-root': {
                  width: 32,
                  height: 32,
                  ml: -0.5,
                  mr: 1,
                },
                '&:before': {
                  content: '""',
                  display: 'block',
                  position: 'absolute',
                  top: 0,
                  right: 14,
                  width: 10,
                  height: 10,
                  bgcolor: 'background.paper',
                  transform: 'translateY(-50%) rotate(45deg)',
                  zIndex: 0,
                },
              },
            }}
            transformOrigin={{ horizontal: 'right', vertical: 'top' }}
            anchorOrigin={{ horizontal: 'right', vertical: 'bottom' }}
          >
            <MenuItem onClick={handleProfileClick}>
              <ListItemIcon>
                <PersonIcon fontSize="small" />
              </ListItemIcon>
              Profilim
            </MenuItem>
            
            {isAdmin(user) && (
              <MenuItem onClick={handleAdminClick}>
                <ListItemIcon>
                  <AdminIcon fontSize="small" />
                </ListItemIcon>
                Admin Paneli
              </MenuItem>
            )}
            
            <Divider />
            
            <MenuItem onClick={handleLogout}>
              <ListItemIcon>
                <LogoutIcon fontSize="small" />
              </ListItemIcon>
              Çıkış Yap
            </MenuItem>
          </Menu>
        </Toolbar>
      </AppBar>
      
      {/* Çekmece */}
      <Box
        component="nav"
        sx={{ width: { sm: drawerWidth }, flexShrink: { sm: 0 } }}
        aria-label="mailbox folders"
      >
        {/* Mobil Çekmece */}
        <Drawer
          variant="temporary"
          open={mobileOpen}
          onClose={handleDrawerToggle}
          ModalProps={{
            keepMounted: true, // Mobil performansı iyileştir
          }}
          sx={{
            display: { xs: 'block', sm: 'none' },
            '& .MuiDrawer-paper': { boxSizing: 'border-box', width: drawerWidth },
          }}
        >
          {drawer}
        </Drawer>
        
        {/* Masaüstü Çekmece */}
        <Drawer
          variant="permanent"
          sx={{
            display: { xs: 'none', sm: 'block' },
            '& .MuiDrawer-paper': { boxSizing: 'border-box', width: drawerWidth },
          }}
          open
        >
          {drawer}
        </Drawer>
      </Box>
      
      {/* Ana İçerik */}
      <Box
        component="main"
        sx={{
          flexGrow: 1,
          p: 3,
          width: { sm: `calc(100% - ${drawerWidth}px)` },
          minHeight: '100vh',
        }}
      >
        <Toolbar /> {/* Üst çubuk için boşluk */}
        <Outlet /> {/* Alt bileşenler */}
      </Box>
    </Box>
  );
};

export default MainLayout; 